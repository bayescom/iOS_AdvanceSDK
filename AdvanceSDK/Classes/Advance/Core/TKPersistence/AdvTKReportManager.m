#import "AdvTKReportManager.h"
#import "AdvTKEvent.h"
#import "AdvTKEventStore.h"
#import "AdvTKTransport.h"
#import "AdvReachability.h"
#import "AdvLog.h"
#import <UIKit/UIKit.h>
#import <math.h>

/// 同时进行的 TK 请求数量上限；其余任务等待空位后发送。
static const NSUInteger AdvTKMaximumConcurrentRequests = 3;

/// 单次 GET 请求的网络超时参数，单位秒；用于设置 NSURLRequest.timeoutInterval。
static const NSTimeInterval AdvTKRequestTimeout = 5;

/// 本地数据库读取、写入或删除失败后的重试间隔，单位秒；不消耗网络补发次数。
static const NSTimeInterval AdvTKStorageRetryInterval = 5;

// 以下四项在 V1 中使用协议默认值；毫秒参数在参与调度时换算为秒。
/// base_ms：网络补发的指数退避基线，单位毫秒；首次失败后等待 5 秒，后续按倍数增长。
static const NSTimeInterval AdvTKBaseMilliseconds = 5000;

/// cap_ms：指数退避间隔上限，单位毫秒；达到 2 分钟后保持该间隔。
/// 服务端 Retry-After 可要求更长的等待时间，但不会延长事件有效期。
static const NSTimeInterval AdvTKCapMilliseconds = 120000;

/// max_retry：网络补发次数上限，不包含首次发送；10 表示总计最多 11 次请求，重启不清零。
static const NSUInteger AdvTKMaximumRetries = 10;

/// expire_ms：事件有效期，单位毫秒；从事件产生时起计算 24 小时，重试和重启均不续期。
static const NSTimeInterval AdvTKExpireMilliseconds = 86400000;

@interface AdvTKAttempt : NSObject
@property (nonatomic, strong) NSURLSessionDataTask *task;
@end
@implementation AdvTKAttempt
@end

@interface AdvTKReportManager ()
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_source_t timer;
@property (nonatomic, strong) AdvTKEventStore *store;
@property (nonatomic, strong) id<AdvTKTransporting> transport;
@property (nonatomic, copy) NSTimeInterval (^clock)(void);
@property (nonatomic, strong) NSMutableDictionary<NSString *, AdvTKEvent *> *events;
@property (nonatomic, strong) NSMutableSet<NSString *> *persistedIds;
@property (nonatomic, strong) NSMutableSet<NSString *> *dirtyIds;
@property (nonatomic, strong) NSMutableSet<NSString *> *removingIds;
@property (nonatomic, strong) NSMutableDictionary<NSString *, AdvTKAttempt *> *inFlight;
@property (nonatomic, strong) AdvReachability *reachability;
@property (nonatomic, assign) NSTimeInterval nextStorageAttemptAt;
@property (nonatomic, assign) BOOL restored;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) BOOL applicationActive;
@property (nonatomic, assign) BOOL observesApplication;
@end

@implementation AdvTKReportManager

+ (instancetype)sharedInstance {
    static AdvTKReportManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *support = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES).firstObject;
        AdvTKEventStore *store = [[AdvTKEventStore alloc] initWithPath:[support stringByAppendingPathComponent:@"AdvanceSDK/TK"]];
        instance = [[self alloc] initWithStore:store transport:[AdvTKTransport new] clock:^{ return NSDate.date.timeIntervalSince1970; }];
        instance.observesApplication = YES;
        instance.applicationActive = NO; // 首次调度等待主线程读取应用状态。
    });
    return instance;
}

// 存储、网络和时钟可独立替换，便于验证断网、重启、磁盘错误和退避行为。
- (instancetype)initWithStore:(AdvTKEventStore *)store
                     transport:(id<AdvTKTransporting>)transport
                         clock:(NSTimeInterval (^)(void))clock {
    if (self = [super init]) {
        _store = store;
        _transport = transport;
        _clock = [clock copy];
        _queue = dispatch_queue_create("com.advancesdk.tk", DISPATCH_QUEUE_SERIAL);
        _events = [NSMutableDictionary dictionary];
        _persistedIds = [NSMutableSet set];
        _dirtyIds = [NSMutableSet set];
        _removingIds = [NSMutableSet set];
        _inFlight = [NSMutableDictionary dictionary];
        _applicationActive = YES;
        _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
        __weak typeof(self) weakSelf = self;
        dispatch_source_set_event_handler(_timer, ^{ [weakSelf drain]; });
        dispatch_source_set_timer(_timer, DISPATCH_TIME_FOREVER, DISPATCH_TIME_FOREVER, 0);
        dispatch_resume(_timer);
    }
    return self;
}

- (void)start {
    dispatch_async(self.queue, ^{
        if (!self.started) {
            self.started = YES;
            if (self.observesApplication) [self observeApplication];
        }
        [self drain];
    });
}

- (void)enqueueURLs:(NSArray<NSString *> *)urls appId:(NSString *)appId eventType:(AdvSupplierReportTKEventType)eventType {
    NSArray *snapshot = [urls copy];
    NSString *sourceAppId = [appId copy] ?: @"";
    NSTimeInterval createdAt = self.clock();
    [self start];
    dispatch_async(self.queue, ^{
        [self cleanupEvents];
        for (NSString *url in snapshot) {
            if (![AdvTKEvent isValidURLString:url]) {
                AdvLog(@"AdvTK 丢弃无效 URL，eventType=%lu", (unsigned long)eventType);
                continue;
            }
            AdvTKEvent *event = [AdvTKEvent new];
            event.taskId = NSUUID.UUID.UUIDString;
            event.appId = sourceAppId;
            event.url = url;
            event.eventType = eventType;
            event.createdAt = createdAt;
            event.expiresAt = createdAt + AdvTKExpireMilliseconds / 1000.0;
            event.nextRetryAt = createdAt;
            self.events[event.taskId] = event;
            [self.dirtyIds addObject:event.taskId];
        }
        // 写入失败的任务仍由当前进程持有，定时重试落盘；落盘前不发送。
        [self drain];
    });
}

- (void)flush {
    dispatch_async(self.queue, ^{ [self drain]; });
}

#pragma mark - Application / connectivity

- (void)observeApplication {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        AdvTKReportManager *manager = weakSelf;
        if (!manager) return;
        NSNotificationCenter *center = NSNotificationCenter.defaultCenter;
        [center addObserver:manager selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [center addObserver:manager selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
        [center addObserver:manager selector:@selector(wake:) name:UIApplicationSignificantTimeChangeNotification object:nil];
        [center addObserver:manager selector:@selector(wake:) name:UIApplicationProtectedDataDidBecomeAvailable object:nil];
        manager.reachability = [AdvReachability reachabilityForInternetConnection];
        manager.reachability.reachableBlock = ^(AdvReachability *reachability) { [weakSelf flush]; };
        [manager.reachability startNotifier];
        BOOL active = UIApplication.sharedApplication.applicationState != UIApplicationStateBackground;
        dispatch_async(manager.queue, ^{
            manager.applicationActive = active;
            [manager drain];
        });
    });
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    dispatch_async(self.queue, ^{
        self.applicationActive = YES;
        [self drain];
    });
}

- (void)applicationDidEnterBackground:(NSNotification *)notification {
    dispatch_async(self.queue, ^{
        self.applicationActive = NO;
        // 已产生的事件继续落盘，不启动新网络请求；不依赖后台定时器持续运行。
        [self drain];
    });
}

- (void)wake:(NSNotification *)notification {
    [self flush];
}

#pragma mark - Store (only on queue)

- (void)storageFailed:(NSError *)error {
    self.nextStorageAttemptAt = self.clock() + AdvTKStorageRetryInterval;
    AdvLog(@"AdvTK 存储失败，将重试：%@", error.localizedDescription);
}

- (void)restoreIfNeeded {
    if (self.restored || self.clock() < self.nextStorageAttemptAt) return;
    NSError *error = nil;
    NSArray<AdvTKEvent *> *stored = [self.store loadEventsWithError:&error];
    if (!stored) {
        [self storageFailed:error];
        return;
    }
    for (AdvTKEvent *event in stored) {
        self.events[event.taskId] = event;
        [self.persistedIds addObject:event.taskId];
    }
    self.restored = YES;
}

- (void)flushLocalChanges {
    if (!self.restored || self.clock() < self.nextStorageAttemptAt) return;
    for (NSString *taskId in self.removingIds.allObjects) {
        NSError *error = nil;
        if (![self.store removeEvent:self.events[taskId] error:&error]) {
            [self storageFailed:error];
            return;
        }
        [self.events removeObjectForKey:taskId];
        [self.persistedIds removeObject:taskId];
        [self.removingIds removeObject:taskId];
    }
    for (NSString *taskId in self.dirtyIds.allObjects) {
        NSError *error = nil;
        if (![self.store saveEvent:self.events[taskId] error:&error]) {
            [self storageFailed:error];
            return;
        }
        [self.persistedIds addObject:taskId];
        [self.dirtyIds removeObject:taskId];
    }
}

- (void)retireEvent:(AdvTKEvent *)event reason:(NSString *)reason {
    if ([self.removingIds containsObject:event.taskId]) return;
    AdvLog(@"AdvTK 结束任务 %@，原因：%@", event.taskId, reason);
    AdvTKAttempt *attempt = self.inFlight[event.taskId];
    [attempt.task cancel];
    attempt.task = nil;
    [self.inFlight removeObjectForKey:event.taskId];
    [self.dirtyIds removeObject:event.taskId];
    if ([self.persistedIds containsObject:event.taskId]) {
        // 服务端确认后若本地删除失败，只重试删除，当前进程内不再次发送。
        [self.removingIds addObject:event.taskId];
    } else {
        [self.events removeObjectForKey:event.taskId];
    }
}

- (void)cleanupEvents {
    NSTimeInterval now = self.clock();
    for (AdvTKEvent *event in self.events.allValues) {
        if (event.expiresAt <= now) {
            [self retireEvent:event reason:@"超过补发有效期"];
        } else if (event.attemptCount > AdvTKMaximumRetries && !self.inFlight[event.taskId]) {
            // 最后一次尝试也会先落盘；重启不能因此重新获得重试额度。
            [self retireEvent:event reason:@"达到最大重试次数"];
        }
    }
}

#pragma mark - Sending / retry

- (NSTimeInterval)retryDelayForAttempt:(NSUInteger)attempt {
    NSUInteger exponent = MIN(attempt ? attempt - 1 : 0, AdvTKMaximumRetries);
    // 首次失败后 5s，之后 10/20/40/80/120s；达到上限后固定 120s。
    return MIN(AdvTKCapMilliseconds, AdvTKBaseMilliseconds * pow(2, exponent)) / 1000.0;
}

- (NSTimeInterval)retryAfter:(NSHTTPURLResponse *)response {
    NSString *value = nil;
    for (id key in response.allHeaderFields) {
        if ([[key description] caseInsensitiveCompare:@"Retry-After"] == NSOrderedSame) {
            value = [response.allHeaderFields[key] description];
            break;
        }
    }
    if (!value.length) return 0;
    NSScanner *scanner = [NSScanner scannerWithString:value];
    double seconds;
    if ([scanner scanDouble:&seconds] && scanner.isAtEnd && isfinite(seconds) && seconds >= 0) return self.clock() + seconds;
    NSDateFormatter *formatter = [NSDateFormatter new];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    formatter.dateFormat = @"EEE',' dd MMM yyyy HH':'mm':'ss 'GMT'";
    return [formatter dateFromString:value].timeIntervalSince1970;
}

- (void)handleResponse:(NSHTTPURLResponse *)response error:(NSError *)error
                event:(AdvTKEvent *)event attempt:(AdvTKAttempt *)attempt {
    attempt.task = nil;
    if (self.inFlight[event.taskId] != attempt) return;
    [self.inFlight removeObjectForKey:event.taskId];
    NSInteger status = response.statusCode;
    if (!error && status >= 200 && status < 300) {
        [self retireEvent:event reason:[NSString stringWithFormat:@"HTTP %ld", (long)status]];
    } else if ((!error && status >= 400 && status < 500 && status != 408 && status != 429) ||
               ([error.domain isEqualToString:NSURLErrorDomain] &&
                (error.code == NSURLErrorBadURL || error.code == NSURLErrorUnsupportedURL))) {
        [self retireEvent:event reason:[NSString stringWithFormat:@"不可重试的响应 HTTP %ld / %@", (long)status, error ?: @""]];
    } else if (event.attemptCount > AdvTKMaximumRetries) {
        [self retireEvent:event reason:@"达到最大重试次数"];
    } else {
        AdvTKEvent *retry = [event copy];
        retry.nextRetryAt = MIN(event.expiresAt, MAX(self.clock() + [self retryDelayForAttempt:event.attemptCount], [self retryAfter:response]));
        self.events[event.taskId] = retry;
        [self.dirtyIds addObject:event.taskId];
        AdvLog(@"AdvTK 等待补发 %@，次数=%lu，HTTP=%ld，错误=%ld", event.taskId, (unsigned long)event.attemptCount, (long)status, (long)error.code);
    }
    [self drain];
}

- (BOOL)sendEvent:(AdvTKEvent *)event {
    // 前面的恢复/批量落盘可能耗时，发送每条任务前重新检查，不能沿用 drain 开始时的时间。
    if (event.expiresAt <= self.clock()) {
        [self retireEvent:event reason:@"发送前超过补发有效期"];
        return YES; // 已处理该任务，继续检查后续任务；NO 专用于存储失败时暂停发送。
    }
    AdvTKEvent *sending = [event copy];
    sending.attemptCount = MIN((NSUInteger)UINT32_MAX, event.attemptCount + 1);
    // 请求前保存尝试状态，重启后保留退避；正常完成时按实际响应更新下次时间。
    sending.nextRetryAt = MIN(event.expiresAt, self.clock() + AdvTKRequestTimeout + [self retryDelayForAttempt:sending.attemptCount]);
    NSError *error = nil;
    if (![self.store saveEvent:sending error:&error]) {
        [self storageFailed:error];
        return NO;
    }
    self.events[event.taskId] = sending;
    // 保存尝试状态期间也可能跨过有效期；已落盘的过期任务转入删除流程，不再发起 GET。
    if (sending.expiresAt <= self.clock()) {
        [self retireEvent:sending reason:@"落盘后超过补发有效期"];
        return YES;
    }
    AdvTKAttempt *attempt = [AdvTKAttempt new];
    self.inFlight[event.taskId] = attempt;
    __weak typeof(self) weakSelf = self;
    attempt.task = [self.transport sendURL:event.url timeout:AdvTKRequestTimeout
                               completion:^(NSHTTPURLResponse *response, NSData *data, NSError *error) {
        AdvTKReportManager *manager = weakSelf;
        if (!manager) return;
        dispatch_async(manager.queue, ^{ [manager handleResponse:response error:error event:sending attempt:attempt]; });
    }];
    return YES;
}

- (void)drain {
    if (!self.started) return;
    [self restoreIfNeeded];
    [self cleanupEvents];
    [self flushLocalChanges];
    if (self.restored && self.applicationActive && self.clock() >= self.nextStorageAttemptAt) {
        NSArray<AdvTKEvent *> *ordered = [self.events.allValues sortedArrayUsingComparator:^NSComparisonResult(AdvTKEvent *a, AdvTKEvent *b) {
            if (a.nextRetryAt != b.nextRetryAt) return a.nextRetryAt < b.nextRetryAt ? NSOrderedAscending : NSOrderedDescending;
            return [a.taskId compare:b.taskId];
        }];
        for (AdvTKEvent *event in ordered) {
            if (self.inFlight.count >= AdvTKMaximumConcurrentRequests) break;
            if (event.nextRetryAt > self.clock() || self.inFlight[event.taskId] ||
                [self.dirtyIds containsObject:event.taskId] || [self.removingIds containsObject:event.taskId]) continue;
            if (![self sendEvent:event]) break;
        }
    }
    [self scheduleNextWake];
}

- (void)scheduleNextWake {
    NSTimeInterval now = self.clock();
    NSTimeInterval deadline = INFINITY;
    if (!self.restored || self.dirtyIds.count || self.removingIds.count) deadline = MAX(now, self.nextStorageAttemptAt);
    for (AdvTKEvent *event in self.events.allValues) {
        if ([self.removingIds containsObject:event.taskId]) continue;
        deadline = MIN(deadline, event.expiresAt);
        if (self.applicationActive && self.restored && self.inFlight.count < AdvTKMaximumConcurrentRequests &&
            !self.inFlight[event.taskId] && ![self.dirtyIds containsObject:event.taskId]) {
            deadline = MIN(deadline, MAX(event.nextRetryAt, self.nextStorageAttemptAt));
        }
    }
    dispatch_time_t time = isfinite(deadline) ? dispatch_time(DISPATCH_TIME_NOW, (int64_t)(MAX(0.05, MIN(3600, deadline - now)) * NSEC_PER_SEC)) : DISPATCH_TIME_FOREVER;
    dispatch_source_set_timer(self.timer, time, DISPATCH_TIME_FOREVER, NSEC_PER_SEC / 10);
}

- (void)dealloc {
    [NSNotificationCenter.defaultCenter removeObserver:self];
    [_reachability stopNotifier];
    if (_timer) dispatch_source_cancel(_timer);
    for (AdvTKAttempt *attempt in _inFlight.allValues) {
        [attempt.task cancel];
        attempt.task = nil;
    }
}

@end
