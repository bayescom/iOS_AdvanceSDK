//
//  AdvAutoLoadManager.m
//  AdvanceSDK
//

#import "AdvAdCacheManager.h"
#import "AdvConstantHeader.h"
#import "AdvDeviceManager.h"
#import "AdvError.h"
#import "AdvAutoLoadManager.h"
#import "AdvPolicyModel.h"
#import "AdvPolicyService+Preload.h"
#import "AdvSupplierLoader.h"
#import "AdvanceCommonAdapter.h"
#import "NSDictionary+Adv.h"
#import "NSMutableDictionary+Adv.h"
#import "NSString+Adv.h"

@interface AdvAutoLoadTask : NSObject <AdvPolicyServicePreloadDelegate, AdvanceCommonSplashAdapterBridge, AdvanceCommonBannerAdapterBridge, AdvanceCommonInterstitialAdapterBridge, AdvanceCommonRewardVideoAdapterBridge, AdvanceCommonFullscreenVideoAdapterBridge, AdvanceCommonNativeExpressAdapterBridge, AdvanceCommonRenderFeedAdapterBridge>

@property (nonatomic, copy) NSString *adspotId;
@property (nonatomic, copy) NSString *supplierSDKID;
@property (nonatomic, copy) NSString *reqId;
@property (nonatomic, copy) NSDictionary *extra;
@property (nonatomic, copy) NSDictionary *adspotConfig;
@property (nonatomic, assign) AdvAutoLoadAdType adType;
@property (nonatomic, strong) AdvPolicyService *policyService;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) id<AdvanceCommonAdapter> adapter;
@property (nonatomic, copy) dispatch_block_t completion;
@property (nonatomic, assign, getter=isFinished) BOOL finished;

- (instancetype)initWithAdspotId:(NSString *)adspotId
                           extra:(nullable NSDictionary *)extra
                    adspotConfig:(NSDictionary *)adspotConfig
                   supplierSDKID:(NSString *)supplierSDKID
                          adType:(AdvAutoLoadAdType)adType;
- (void)start;

@end

@interface AdvAutoLoadManager ()
@property (nonatomic, strong) NSMutableDictionary<NSString *, AdvAutoLoadTask *> *activeTasks;
@end

@implementation AdvAutoLoadManager

+ (instancetype)sharedInstance {
    static AdvAutoLoadManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    if (self = [super init]) {
        _activeTasks = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)preloadAdspotId:(NSString *)adspotId
                  extra:(NSDictionary *)extra
           adspotConfig:(NSDictionary *)adspotConfig
               supplier:(AdvSupplier *)supplier
                 adType:(AdvAutoLoadAdType)adType {
    if (!adspotId.length || !supplier.sdk_id.length || !supplier.enable_cache) {
        return;
    }
    
    // 如果普通请求或其他任务已在曝光回调期间填充共享缓存，则不再重复加载。
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        return;
    }
    
    NSString *taskKey = [self taskKeyForAdspotId:adspotId supplierSDKID:supplier.sdk_id adType:adType];
    if (self.activeTasks[taskKey]) {
        return;
    }
    
    AdvAutoLoadTask *task = [[AdvAutoLoadTask alloc] initWithAdspotId:adspotId
                                                                extra:extra
                                                         adspotConfig:adspotConfig
                                                        supplierSDKID:supplier.sdk_id
                                                               adType:adType];
    __weak typeof(self) weakSelf = self;
    __weak AdvAutoLoadTask *weakTask = task;
    task.completion = ^{
        AdvAutoLoadManager *strongSelf = weakSelf;
        AdvAutoLoadTask *finishedTask = weakTask;
        if (strongSelf && finishedTask && strongSelf.activeTasks[taskKey] == finishedTask) {
            [strongSelf.activeTasks removeObjectForKey:taskKey];
        }
    };
    self.activeTasks[taskKey] = task;
    [task start];
}

- (NSString *)taskKeyForAdspotId:(NSString *)adspotId supplierSDKID:(NSString *)supplierSDKID adType:(AdvAutoLoadAdType)adType {
    return [NSString stringWithFormat:@"%lu:%@:%lu:%@:%lu",
            (unsigned long)adspotId.length, adspotId,
            (unsigned long)supplierSDKID.length, supplierSDKID,
            (unsigned long)adType];
}

@end

@implementation AdvAutoLoadTask

- (instancetype)initWithAdspotId:(NSString *)adspotId
                           extra:(NSDictionary *)extra
                    adspotConfig:(NSDictionary *)adspotConfig
                   supplierSDKID:(NSString *)supplierSDKID
                          adType:(AdvAutoLoadAdType)adType {
    if (self = [super init]) {
        _adspotId = [adspotId copy];
        _supplierSDKID = [supplierSDKID copy];
        _reqId = [AdvDeviceManager getUUID];
        _extra = [extra copy] ?: @{};
        _adspotConfig = [adspotConfig copy] ?: @{};
        _adType = adType;
        _policyService = [AdvPolicyService manager];
        _policyService.delegate = self;
    }
    return self;
}

- (void)start {
    [self.policyService adv_loadPolicyDataWithAdspotId:self.adspotId
                                                 reqId:self.reqId
                                                 extra:self.extra
                                  preloadSupplierSDKID:self.supplierSDKID];
}

- (void)finish {
    if (self.isFinished) {
        return;
    }
    self.finished = YES;
    self.policyService.delegate = nil;
    self.adapter = nil;
    self.supplier = nil;
    
    dispatch_block_t completion = self.completion;
    self.completion = nil;
    if (completion) {
        completion();
    }
    self.policyService = nil;
}

#pragma mark - AdvPolicyServiceDelegate

- (void)policyServiceLoadFailedWithError:(NSError *)error {
    [self finish];
}

- (void)policyServicePreloadDidFailWithError:(NSError *)error {
    [self finish];
}

- (void)policyServiceLoadSuccessWithModel:(AdvPolicyModel *)model {
    if (self.adType != AdvAutoLoadAdTypeRewardVideo) {
        return;
    }
    NSMutableDictionary *config = [self.adspotConfig mutableCopy] ?: [NSMutableDictionary dictionary];
    [config adv_safeSetObject:model.server_reward.name forKey:kAdvanceServerRewardNameKey];
    [config adv_safeSetObject:@(model.server_reward.count) forKey:kAdvanceServerRewardCountKey];
    self.adspotConfig = config.copy;
}

- (void)policyServiceLoadAnySupplier:(AdvSupplier *)supplier
                       cachedAdModel:(AdvAdCacheModel *)cachedAdModel {
    if (self.isFinished || ![supplier.sdk_id isEqualToString:self.supplierSDKID] || !supplier.enable_cache) {
        [self.policyService adv_cancelPreloadForSupplier:supplier];
        [self finish];
        return;
    }
    
    // 策略请求期间普通请求可能已填充缓存；策略服务已据此跳过渠道请求次数，本任务无需重复请求。
    if (cachedAdModel) {
        [self.policyService adv_cancelPreloadForSupplier:supplier];
        [self finish];
        return;
    }
    
    self.supplier = supplier;
    switch (self.adType) {
        case AdvAutoLoadAdTypeSplash: {
            id<AdvanceCommonSplashAdapter> adapter = [AdvSupplierLoader createSplashAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setSplashBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeBanner: {
            id<AdvanceCommonBannerAdapter> adapter = [AdvSupplierLoader createBannerAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setBannerBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeInterstitial: {
            id<AdvanceCommonInterstitialAdapter> adapter = [AdvSupplierLoader createInterstitialAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setInterstitialBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeRewardVideo: {
            id<AdvanceCommonRewardVideoAdapter> adapter = [AdvSupplierLoader createRewardVideoAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setRewardVideoBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeFullscreenVideo: {
            id<AdvanceCommonFullscreenVideoAdapter> adapter = [AdvSupplierLoader createFullScreenVideoAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setFullscreenBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeNativeExpress: {
            id<AdvanceCommonNativeExpressAdapter> adapter = [AdvSupplierLoader createNativeExpressAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setNativeExpressBridge:self];
            break;
        }
        case AdvAutoLoadAdTypeRenderFeed: {
            id<AdvanceCommonRenderFeedAdapter> adapter = [AdvSupplierLoader createRenderFeedAdapterWithSupplierId:supplier.identifier];
            self.adapter = adapter;
            [adapter adapter_setRenderFeedBridge:self];
            break;
        }
    }
    if (!self.adapter) {
        NSError *error = [AdvError errorWithCode:AdvErrorCode_CustomAdnLoadFailed].toNSError;
        [self.policyService adv_finishPreloadForSupplier:supplier price:0 error:error];
        [self finish];
        return;
    }

    [self.adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
}

- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:
                                   [NSString adv_dictionaryWithJsonString:supplier.custom_params]];
    [config addEntriesFromDictionary:self.adspotConfig];
    if (self.adType == AdvAutoLoadAdTypeSplash) {
        [config adv_safeSetObject:@(supplier.timeout) forKey:kAdvanceAdLoadTimeoutKey];
    }
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    return config.copy;
}

#pragma mark - Adapter callbacks

- (void)handleLoadSuccessWithAdapter:(id<AdvanceCommonAdapter>)adapter price:(NSInteger)price {
    [self performOnMainThread:^{
        if (self.isFinished || adapter != self.adapter || !self.supplier) {
            return;
        }
        if (![self.policyService adv_finishPreloadForSupplier:self.supplier price:price error:nil]) {
            [self finish];
            return;
        }
        [[AdvAdCacheManager sharedInstance] cacheAdapterIfAbsent:adapter
                                                           price:price
                                                      expireTime:self.supplier.cache_timeout
                                                     sourceReqId:self.reqId
                                                          forKey:self.supplier.sdk_id];
        [self finish];
    }];
}

- (void)handleLoadFailureWithAdapter:(id<AdvanceCommonAdapter>)adapter error:(NSError *)error {
    [self performOnMainThread:^{
        if (self.isFinished || adapter != self.adapter || !self.supplier) {
            return;
        }
        [self.policyService adv_finishPreloadForSupplier:self.supplier price:0 error:error];
        [self finish];
    }];
}

- (void)splash_didLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)splash_failedToLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)banner_didLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)banner_failedToLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)interstitial_didLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)interstitial_failedToLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)rewardVideo_didLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)rewardVideo_failedToLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)fullscreen_didLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)fullscreen_failedToLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)nativeExpress_didLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)nativeExpress_failedToLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

- (void)renderFeed_didLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter price:(NSInteger)price {
    [self handleLoadSuccessWithAdapter:adapter price:price];
}

- (void)renderFeed_failedToLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter error:(NSError *)error {
    [self handleLoadFailureWithAdapter:adapter error:error];
}

// 自动预加载的广告不直接展示，因此忽略展示、曝光、点击、关闭和奖励回调。
- (void)splash_didAdExposuredWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {}
- (void)splash_failedToShowAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error {}
- (void)splash_didAdClickedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {}
- (void)splash_didAdClosedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {}
- (void)banner_didAdExposuredWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {}
- (void)banner_failedToShowAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error {}
- (void)banner_didAdClickedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {}
- (void)banner_didAdClosedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {}
- (void)interstitial_didAdExposuredWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {}
- (void)interstitial_failedToShowAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error {}
- (void)interstitial_didAdClickedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {}
- (void)interstitial_didAdClosedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {}
- (void)rewardVideo_didAdExposuredWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {}
- (void)rewardVideo_failedToShowAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error {}
- (void)rewardVideo_didAdClickedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {}
- (void)rewardVideo_didAdClosedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {}
- (void)rewardVideo_didAdVerifyRewardWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {}
- (void)rewardVideo_didAdPlayFinishWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {}
- (void)fullscreen_didAdExposuredWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {}
- (void)fullscreen_failedToShowAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error {}
- (void)fullscreen_didAdClickedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {}
- (void)fullscreen_didAdClosedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {}
- (void)fullscreen_didAdPlayFinishWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {}
- (void)nativeExpress_didAdRenderSuccessWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {}
- (void)nativeExpress_didAdRenderFailWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView error:(NSError *)error {}
- (void)nativeExpress_didAdExposuredWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {}
- (void)nativeExpress_didAdClickedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {}
- (void)nativeExpress_didAdClosedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {}
- (void)renderFeed_didAdExposuredWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {}
- (void)renderFeed_didAdClickedWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {}
- (void)renderFeed_didAdClosedDetailPageWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {}
- (void)renderFeed_didAdPlayFinishWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {}

- (void)performOnMainThread:(dispatch_block_t)block {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

@end
