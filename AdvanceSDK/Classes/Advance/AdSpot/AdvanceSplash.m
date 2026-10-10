
#import "AdvanceSplash.h"
#import "AdvAutoLoadManager.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"
#import "AdvFrequencyControlManager.h"

@interface AdvanceSplash () <AdvPolicyServiceDelegate, AdvanceCommonSplashAdapterBridge>

@end

@implementation AdvanceSplash

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceSplashDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameSplash forKey:AdvSdkTypeAdName];
    
    if (self = [super initWithAdspotId:adspotid extra:extraDict.copy]) {
        self.delegate = delegate;
    }
    return self;
}

- (AdvanceAdInfo *)getAdInfo {
    if (self.targetAdapter) {
        AdvSupplier *supplier = [self getSupplierWithAdapter:self.targetAdapter];
        return [supplier transformAdnInfo];
    }
    return nil;
}

#pragma mark: - AdvPolicyServiceDelegate
/// 广告策略加载成功
- (void)policyServiceLoadSuccessWithModel:(nonnull AdvPolicyModel *)model {
}

/// 广告策略加载失败
- (void)policyServiceLoadFailedWithError:(nullable NSError *)error {
    /// 获取开屏广告失败
    if ([_delegate respondsToSelector:@selector(onSplashAdFailToLoad:error:)]) {
        [_delegate onSplashAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// 开始Bidding
- (void)policyServiceStartBiddingWithSuppliers:(NSArray <AdvSupplier *> *_Nullable)suppliers {
    [self.suppliers addObjectsFromArray:suppliers];
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier
                       cachedAdModel:(nullable AdvAdCacheModel *)cachedAdModel {
    id<AdvanceCommonSplashAdapter> adapter;
    if (supplier.enable_cache && cachedAdModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
        supplier.cachedReqId = cachedAdModel.sourceReqId; //用于tk上报
        adapter = cachedAdModel.adObject;
        [self.adapterMap adv_safeSetObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setSplashBridge:self];
        [self splash_didLoadAdWithAdapter:adapter price:cachedAdModel.price];
    } else {// 根据渠道id初始化对应Adapter
        adapter = [AdvSupplierLoader createSplashAdapterWithSupplierId:supplier.identifier];
        if (adapter) {
            [self.adapterMap adv_safeSetObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setSplashBridge:self];
            [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
        } else { // 开发者自定义adapter类不存在
            [(AdvPolicyService *)self.manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:[AdvError errorWithCode:AdvErrorCode_CustomAdnLoadFailed].toNSError];
        }
    }
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取开屏广告失败
    if ([_delegate respondsToSelector:@selector(onSplashAdFailToLoad:error:)]) {
        [_delegate onSplashAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    //    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取开屏广告成功
    if ([_delegate respondsToSelector:@selector(onSplashAdDidLoad:)]) {
        [_delegate onSplashAdDidLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonSplashAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
    
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonSplashAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
    if ([adapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [adapter adapter_sendNotificationWithBidResult:bidResult];
    }
}


#pragma mark: - load & show
- (void)loadAd {
    [super loadAdPolicy];
}

- (void)showAdInWindow:(UIWindow *)window {
    /// 广告位曝光和点击频控校验
    NSError *frequencyError = [[AdvFrequencyControlManager sharedInstance] canDisplayAdForAdspotId:self.adspotid];
    if (frequencyError) {
        [self splash_failedToShowAdWithAdapter:self.targetAdapter error:frequencyError];
        return;
    }
    if (self.targetAdapter) {
        /// 渠道曝光和点击频控校验
        AdvSupplier *targetSupplier = [self getSupplierWithAdapter:self.targetAdapter];
        NSError *supplierFrequencyError = [[AdvFrequencyControlManager sharedInstance] canDisplayAdForSupplier:targetSupplier];
        if (supplierFrequencyError) {
            [self splash_failedToShowAdWithAdapter:self.targetAdapter error:supplierFrequencyError];
            return;
        }

        /// 调用展示即可删除缓存，不必等曝光成功后删除，假设展示失败该缓存下次调用展示依旧会失败，没有留下的必要。
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:targetSupplier.sdk_id
                                                            matchingAdapter:self.targetAdapter];
        /// 预加载即将展示的渠道广告
        [self scheduleAutoLoadIfNeededWithSupplier:targetSupplier];
    }
    if (![self isAdValid]) {
        return;
    }
    if (!window) {
        window = [UIWindow adv_getCurrentWindow];
    }
    if (!self.viewController) {
        self.viewController = window.rootViewController;
    }
    [self.targetAdapter adapter_showAdInWindow:window];
}

- (BOOL)isAdValid {
    if (!self.targetAdapter) {
        NSError *error = [AdvError errorWithCode:AdvErrorCode_AdNotReady].toNSError;
        if ([self.delegate respondsToSelector:@selector(onSplashAdFailToPresent:error:)]) {
            [self.delegate onSplashAdFailToPresent:self error:error];
        }
        return NO;
    }
    if ([(id<AdvanceCommonSplashAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        BOOL valid = [self.targetAdapter adapter_isAdValid];
        if (!valid) {
            [self splash_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
        }
        return valid;
    }
    return YES;
}

#pragma mark: - AdvanceCommonSplashAdapterBridge
- (void)splash_didLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter price:(NSInteger)price {
    [self performAdapterLoadResultOnMainThread:^{
        AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
        if (supplier.enable_cache) { // 先缓存，当前受频控限制时仍可在后续策略请求中尝试
            [[AdvAdCacheManager sharedInstance] cacheAdapterIfAbsent:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
        }
        NSError *frequencyError = [[AdvFrequencyControlManager sharedInstance] canDisplayAdForSupplier:supplier];
        if (frequencyError) {
            [self splash_failedToLoadAdWithAdapter:adapter error:frequencyError];
            return;
        }
        AdvPolicyService *manager = self.manager;
        [manager setECPMIfNeeded:price supplier:supplier];
        [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
    }];
}

- (void)splash_failedToLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error {
    [self performAdapterLoadResultOnMainThread:^{
        AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
        AdvPolicyService *manager = self.manager;
        [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
    }];
}

/// 竞胜的渠道广告执行以下回调
- (void)splash_didAdExposuredWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (!self.isImpressionCounted) {
        self.isImpressionCounted = YES;
        [[AdvFrequencyControlManager sharedInstance] recordValidImpressionForAdspotId:self.adspotid];
        [[AdvFrequencyControlManager sharedInstance] recordValidImpressionForSupplier:supplier];
    }
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onSplashAdExposured:)]) {
        [self.delegate onSplashAdExposured:self];
    }
}

- (void)splash_failedToShowAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onSplashAdFailToPresent:error:)]) {
        [self.delegate onSplashAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)splash_didAdClickedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (!self.isClickCounted) {
        self.isClickCounted = YES;
        [[AdvFrequencyControlManager sharedInstance] recordClickForAdspotId:self.adspotid];
        [[AdvFrequencyControlManager sharedInstance] recordClickForSupplier:supplier];
    }
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onSplashAdClicked:)]) {
        [self.delegate onSplashAdClicked:self];
    }
}

- (void)splash_didAdClosedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onSplashAdClosed:)]) {
        [self.delegate onSplashAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

#pragma mark: - setting
- (NSDictionary *)setupAdspotSpecificConfig {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:self.viewController forKey:kAdvanceAdPresentControllerKey];
    [config adv_safeSetObject:self.bottomLogoView forKey:kAdvanceSplashBottomViewKey];
    return config.copy;
}

- (void)scheduleAutoLoadIfNeededWithSupplier:(AdvSupplier *)supplier {
    if (self.didScheduleAutoLoad || !supplier.enable_cache) {
        return;
    }
    self.didScheduleAutoLoad = YES;
    NSString *adspotId = [self.adspotid copy];
    NSDictionary *extra = self.extraDict.copy;
    NSDictionary *adspotConfig = [self setupAdspotSpecificConfig];
    AdvSupplier *cachedSupplier = supplier;
    dispatch_async(dispatch_get_main_queue(), ^{
        [[AdvAutoLoadManager sharedInstance] preloadAdspotId:adspotId
                                                       extra:extra
                                                adspotConfig:adspotConfig
                                                    supplier:cachedSupplier
                                                      adType:AdvAutoLoadAdTypeSplash];
    });
}

- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    // 先获取supplier.custom_params
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:[NSString adv_dictionaryWithJsonString:supplier.custom_params]];
    [config adv_safeSetObject:@(supplier.timeout) forKey:kAdvanceAdLoadTimeoutKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    [config addEntriesFromDictionary:[self setupAdspotSpecificConfig]];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    NSString *foundKey = [self.adapterMap.allKeys adv_filter:^BOOL(NSString *key) {
        return self.adapterMap[key] == adapter;
    }].firstObject;
    return [self.suppliers adv_filter:^BOOL(AdvSupplier *obj) {
        return [obj.sdk_id isEqualToString:foundKey];
    }].firstObject;
}

- (void)dealloc {
    
}

@end
