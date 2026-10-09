//
//  AdvFrequencyControlManager.m
//  AdvanceSDK
//

#import "AdvFrequencyControlManager.h"
#import "AdvConfigCacheManager.h"
#import "AdvDeviceManager.h"
#import "AdvYYCache.h"
#import "AdvError.h"

static NSString * const AdvFrequencyControlRecordKey = @"AdvFrequencyControlRecordKey";

@interface AdvFrequencyControlRecord : NSObject <NSCoding>

@property (nonatomic, copy) NSString *dayIdentifier;
@property (nonatomic, assign) NSInteger requestCount;
@property (nonatomic, assign) NSInteger impressionCount;
@property (nonatomic, assign) NSInteger clickCount;
/// 最近一次聚合策略加载的毫秒时间戳，不随自然日切换清零。
@property (nonatomic, assign) NSTimeInterval lastRequestTimestamp;

@end

@implementation AdvFrequencyControlRecord

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.dayIdentifier = [aDecoder decodeObjectForKey:@"dayIdentifier"];
        self.requestCount = [aDecoder decodeIntegerForKey:@"requestCount"];
        self.impressionCount = [aDecoder decodeIntegerForKey:@"impressionCount"];
        self.clickCount = [aDecoder decodeIntegerForKey:@"clickCount"];
        self.lastRequestTimestamp = [aDecoder decodeDoubleForKey:@"lastRequestTimestamp"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.dayIdentifier forKey:@"dayIdentifier"];
    [aCoder encodeInteger:self.requestCount forKey:@"requestCount"];
    [aCoder encodeInteger:self.impressionCount forKey:@"impressionCount"];
    [aCoder encodeInteger:self.clickCount forKey:@"clickCount"];
    [aCoder encodeDouble:self.lastRequestTimestamp forKey:@"lastRequestTimestamp"];
}

@end

@interface AdvFrequencyControlManager ()

@property (nonatomic, strong) AdvYYCache *frequencyCache;
/// 校验与计数提交共用串行队列，防止并发请求穿透次数和间隔限制。
@property (nonatomic, strong) dispatch_queue_t transactionQueue;

@end

@implementation AdvFrequencyControlManager

+ (instancetype)sharedInstance {
    static AdvFrequencyControlManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _frequencyCache = [AdvYYCache cacheWithName:@"AdvFrequencyControl"];
        _transactionQueue = dispatch_queue_create("com.advancesdk.frequency-control", DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

- (NSError *)consumeRequestQuotaForAdspotId:(NSString *)adspotId {
    if (!adspotId.length) {
        return nil;
    }

    __block NSError *frequencyError = nil;
    dispatch_sync(self.transactionQueue, ^{
        AdvFrequencyControlRecord *record = [self recordForAdspotId:adspotId];
        AdvanceAdspotConfig *config = [self adspotConfigForAdspotId:adspotId];

        // 曝光、点击、请求次数和间隔在同一事务中校验，通过后再提交请求计数。
        frequencyError = [self impressionOrClickLimitErrorWithConfig:config record:record];
        if (!frequencyError && config.req_limit > 0 && record.requestCount >= config.req_limit) {
            frequencyError = [AdvError errorWithCode:AdvErrorCode_RequestDailyLimit].toNSError;
        }

        NSTimeInterval now = [NSDate date].timeIntervalSince1970 * 1000;
        NSTimeInterval elapsed = now - record.lastRequestTimestamp;
        if (!frequencyError && config.req_interval > 0 && record.lastRequestTimestamp > 0 &&
            elapsed >= 0 && elapsed < config.req_interval) {
            frequencyError = [AdvError errorWithCode:AdvErrorCode_RequestIntervalLimit].toNSError;
        }

        if (frequencyError) {
            return;
        }

        record.requestCount += 1;
        record.lastRequestTimestamp = now;
        [self persistRecord:record adspotId:adspotId];
    });
    return frequencyError;
}

- (NSError *)consumePreloadRequestCountForAdspotId:(NSString *)adspotId {
    if (!adspotId.length) {
        return nil;
    }

    __block NSError *frequencyError = nil;
    dispatch_sync(self.transactionQueue, ^{
        AdvFrequencyControlRecord *record = [self recordForAdspotId:adspotId];
        AdvanceAdspotConfig *config = [self adspotConfigForAdspotId:adspotId];

        if (config.req_limit > 0 && record.requestCount >= config.req_limit) {
            frequencyError = [AdvError errorWithCode:AdvErrorCode_RequestDailyLimit].toNSError;
            return;
        }

        // 预加载只占用每日请求次数，不更新时间间隔用的时间戳。
        record.requestCount += 1;
        [self persistRecord:record adspotId:adspotId];
    });
    return frequencyError;
}

- (NSError *)canDisplayAdForAdspotId:(NSString *)adspotId {
    if (!adspotId.length) {
        return nil;
    }

    __block NSError *frequencyError = nil;
    dispatch_sync(self.transactionQueue, ^{
        AdvFrequencyControlRecord *record = [self recordForAdspotId:adspotId];
        AdvanceAdspotConfig *config = [self adspotConfigForAdspotId:adspotId];
        frequencyError = [self impressionOrClickLimitErrorWithConfig:config record:record];
    });
    return frequencyError;
}

- (void)recordValidImpressionForAdspotId:(NSString *)adspotId {
    [self updateRecordForAdspotId:adspotId block:^(AdvFrequencyControlRecord *record) {
        record.impressionCount += 1;
    }];
}

- (void)recordClickForAdspotId:(NSString *)adspotId {
    [self updateRecordForAdspotId:adspotId block:^(AdvFrequencyControlRecord *record) {
        record.clickCount += 1;
    }];
}

- (void)updateRecordForAdspotId:(NSString *)adspotId
                        block:(void (^)(AdvFrequencyControlRecord *record))block {
    if (!adspotId.length || !block) {
        return;
    }
    dispatch_sync(self.transactionQueue, ^{
        AdvFrequencyControlRecord *record = [self recordForAdspotId:adspotId];
        block(record);
        [self persistRecord:record adspotId:adspotId];
    });
}

- (AdvanceAdspotConfig *)adspotConfigForAdspotId:(NSString *)adspotId {
    AdvanceSDKConfig *sdkConfig = [[AdvConfigCacheManager sharedInstance] sdkConfig];
    AdvanceAdspotConfig *config = sdkConfig.adspot_configs[adspotId];
    if (config) {
        return config;
    }
    // 兼容服务端字典 key 与对象 adspot_id 不一致的数据。
    for (AdvanceAdspotConfig *candidate in sdkConfig.adspot_configs.allValues) {
        if ([candidate.adspot_id isEqualToString:adspotId]) {
            return candidate;
        }
    }
    return nil;
}

- (NSError *)impressionOrClickLimitErrorWithConfig:(AdvanceAdspotConfig *)config
                                         record:(AdvFrequencyControlRecord *)record {
    if (config.imp_limit > 0 && record.impressionCount >= config.imp_limit) {
        return [AdvError errorWithCode:AdvErrorCode_ImpressionDailyLimit].toNSError;
    }
    if (config.click_limit > 0 && record.clickCount >= config.click_limit) {
        return [AdvError errorWithCode:AdvErrorCode_ClickDailyLimit].toNSError;
    }
    return nil;
}

- (AdvFrequencyControlRecord *)recordForAdspotId:(NSString *)adspotId {
    NSString *key = [self recordKeyForAdspotId:adspotId];
    AdvFrequencyControlRecord *record = (AdvFrequencyControlRecord *)[self.frequencyCache objectForKey:key];
    if (!record) {
        record = [[AdvFrequencyControlRecord alloc] init];
    }

    NSString *today = [self currentDayIdentifier];
    if (![record.dayIdentifier isEqualToString:today]) {
        record.dayIdentifier = today;
        record.requestCount = 0;
        record.impressionCount = 0;
        record.clickCount = 0;
        [self.frequencyCache setObject:record forKey:key];
    }
    return record;
}

- (void)persistRecord:(AdvFrequencyControlRecord *)record adspotId:(NSString *)adspotId {
    [self.frequencyCache setObject:record forKey:[self recordKeyForAdspotId:adspotId]];
}

- (NSString *)recordKeyForAdspotId:(NSString *)adspotId {
    NSString *appId = [AdvDeviceManager sharedInstance].appId ?: @"";
    return [NSString stringWithFormat:@"%@:%lu:%@:%@", AdvFrequencyControlRecordKey,
            (unsigned long)appId.length, appId, adspotId];
}

- (NSString *)currentDayIdentifier {
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay
                                                                 fromDate:[NSDate date]];
    return [NSString stringWithFormat:@"%04ld-%02ld-%02ld",
            (long)components.year, (long)components.month, (long)components.day];
}

@end
