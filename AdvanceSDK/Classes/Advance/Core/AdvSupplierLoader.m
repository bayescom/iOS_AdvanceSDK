//
//  AdvSupplierLoader.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import "AdvSupplierLoader.h"
#import "AdvConstantHeader.h"
#import "AdvError.h"
#import "AdvAdapterRepository.h"
#import "objc/message.h"

@interface AdvSupplierLoader ()
// 状态表：平台id -> 当前初始化状态 @(AdvAdnInitState)
@property (nonatomic, strong, class) NSMutableDictionary <NSString *, NSNumber *> *initializeStatus;
// 回调队列：平台id -> NSMutableArray<Completion.copy>
@property (nonatomic, strong, class) NSMutableDictionary <NSString *, NSMutableArray *> *pendingCompletions;

@end

static NSMutableDictionary *_initializeStatus = nil;
static NSMutableDictionary *_pendingCompletions = nil;

@implementation AdvSupplierLoader

+ (NSMutableDictionary *)initializeStatus {
    if (!_initializeStatus) {
        _initializeStatus = [NSMutableDictionary dictionary];
    }
    return _initializeStatus;
}

+ (void)setInitializeStatus:(NSMutableDictionary *)initializeStatus {
    _initializeStatus = initializeStatus;
}

+ (NSMutableDictionary *)pendingCompletions {
    if (!_pendingCompletions) {
        _pendingCompletions = [NSMutableDictionary dictionary];
    }
    return _pendingCompletions;
}

+ (void)setPendingCompletions:(NSMutableDictionary *)pendingCompletions {
    _pendingCompletions = pendingCompletions;
}

// 加载渠道SDK进行初始化调用
+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(NSError *error))completion {
    // 渠道初始化状态和等待队列统一由主线程管理，避免多个广告请求同时进入时产生数据竞争
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadSupplier:supplier completion:completion];
        });
        return;
    }

    NSAssert([NSThread isMainThread], @"AdvSupplierLoader must initialize suppliers on the main thread");

    Class adapterClass = [self createConfigAdapterClassWithSupplierId:supplier.identifier];
    /// 媒体未引入渠道SDK或Adapter
    if (!adapterClass) {
        NSError *error = [AdvError errorWithCode:AdvErrorCode_SupplierUninstalled].toNSError;
        if (supplier.is_custom_adn) {
            error = [AdvError errorWithCode:AdvErrorCode_CustomAdnLoadFailed].toNSError;
        }
        dispatch_async(dispatch_get_main_queue(), ^{ // 将当前调用延迟到下一个 RunLoop 周期执行。
            completion(error);
        });
        return;
    }
    
    /// 初始化该平台的队列与状态
    if (!self.pendingCompletions[supplier.identifier]) {
        self.pendingCompletions[supplier.identifier] = [NSMutableArray array];
        self.initializeStatus[supplier.identifier] = @(AdvAdnInitStateDefault);
    }
    
    AdvAdnInitState currentState = [self.initializeStatus[supplier.identifier] intValue];
    /// 已经初始化成功 直接回调
    if (currentState == AdvAdnInitStateSuccess) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
        return;
    }
    
    /// 将当前 completion 放入回调队列 (必须 copy 到堆上)
    if (completion) {
        [self.pendingCompletions[supplier.identifier] addObject:[completion copy]];
    }
    
    /// 正在初始化中 后续并发进入的广告源
    if (currentState == AdvAdnInitStateLoading) {
        // 上面已经把 completion 塞入 queue 了，这里静静等待第一次初始化的结果返回即可
        return;
    }
    
    /// 之前失败了，或者为默认状态 -> 触发正式初始化
    self.initializeStatus[supplier.identifier] = @(AdvAdnInitStateLoading);
    
    /// 第一个广告源进来，开始执行初始化
    SEL initSelector = NSSelectorFromString(@"initializeAdapterWithAppId:appKey:completion:");
    if ([adapterClass respondsToSelector:initSelector]) {
        // 定义block
        void (^completionHandler)(NSError *error) = ^void (NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.initializeStatus[supplier.identifier] = !error ? @(AdvAdnInitStateSuccess) : @(AdvAdnInitStateFailed);
                [self executePendingCompletionsWithSupplier:supplier error:[self wrappedError:error]];
            });
        };
        ((void (*)(id, SEL, id, id, id))objc_msgSend)(adapterClass, initSelector, supplier.mediaid, supplier.mediakey, completionHandler);
    } else { // 只有自定义ADN才会进入
        dispatch_async(dispatch_get_main_queue(), ^{
            self.initializeStatus[supplier.identifier] = @(AdvAdnInitStateFailed);
            [self executePendingCompletionsWithSupplier:supplier error:[AdvError errorWithCode:-100 message:@"自定义ADN未遵循初始化协议"].toNSError];
        });
    }
}

/// 执行所有等待中的回调
+ (void)executePendingCompletionsWithSupplier:(AdvSupplier *)supplier error:(NSError *)error {
    NSMutableArray *queue = self.pendingCompletions[supplier.identifier];
    // 拷贝一份回调列表，避免在回调执行过程中外部又往队列里塞数据导致崩溃
    NSArray *completions = [queue copy];
    [queue removeAllObjects];
    for (void(^completion)(NSError *) in completions) {
        if (completion) {
            completion(error);
        }
    }
}

/// 包装成更容易识别的错误信息
+ (NSError *)wrappedError:(NSError *)error {
    if (error) {
        NSError *wrappedError = [AdvError errorWithCode:AdvErrorCode_SupplierInitFailed message:error.userInfo[NSLocalizedDescriptionKey]].toNSError;
        return wrappedError;
    }
    return nil;
}

+ (Class)createConfigAdapterClassWithSupplierId:(NSString *)supplierId {
    return [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId].configAdapterClass;
}

+ (id)createSplashAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.splashAdapterClass alloc] init];
}

+ (id)createInterstitialAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.interstitialAdapterClass alloc] init];
}

+ (id)createRewardVideoAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.rewardVideoAdapterClass alloc] init];
}

+ (id)createFullScreenVideoAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.fullScreenVideoAdapterClass alloc] init];
}

+ (id)createNativeExpressAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.nativeExpressAdapterClass alloc] init];
}

+ (id)createRenderFeedAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.renderFeedAdapterClass alloc] init];
}

+ (id)createBannerAdapterWithSupplierId:(NSString *)supplierId {
    AdvAdapterDescriptor *descriptor = [[AdvAdapterRepository sharedInstance] descriptorForSupplierId:supplierId];
    return [[descriptor.bannerAdapterClass alloc] init];
}

@end
