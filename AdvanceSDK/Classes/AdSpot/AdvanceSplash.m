
#import "AdvanceSplash.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"

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
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    id<AdvanceCommonSplashAdapter> adapter;
    // 尝试获取Adapter缓存
    AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
    if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
        supplier.cachedReqId = cacheModel.sourceReqId; //用于tk上报
        adapter = cacheModel.adObject;
        [self.adapterMap adv_safeSetObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setSplashBridge:self];
        [self splash_didLoadAdWithAdapter:adapter price:cacheModel.price];
    } else {// 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingSplashAdapterNameWithSupplierId:supplier.identifier];
        adapter = [[NSClassFromString(clsName) alloc] init];
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
    if (![self isAdValid]) {
        return;
    }
    if (!window) {
        window = [UIApplication sharedApplication].adv_getCurrentWindow;
    }
    if (!self.viewController) {
        self.viewController = window.rootViewController;
    }
    [self.targetAdapter adapter_showAdInWindow:window];
}

- (BOOL)isAdValid {
    BOOL valid = YES;
    if ([(id<AdvanceCommonSplashAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        valid = [self.targetAdapter adapter_isAdValid];
    }
    if (!valid) {
        [self splash_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - AdvanceCommonSplashAdapterBridge
- (void)splash_didLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)splash_failedToLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)splash_didAdExposuredWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onSplashAdExposured:)]) {
        [self.delegate onSplashAdExposured:self];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
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
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)splash_didAdClickedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
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
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    // 先获取supplier.custom_params
    NSMutableDictionary *config = [NSMutableDictionary dictionaryWithDictionary:[NSString adv_dictionaryWithJsonString:supplier.custom_params]];
    [config adv_safeSetObject:self.viewController forKey:kAdvanceAdPresentControllerKey];
    [config adv_safeSetObject:self.bottomLogoView forKey:kAdvanceSplashBottomViewKey];
    [config adv_safeSetObject:@(supplier.timeout) forKey:kAdvanceAdLoadTimeoutKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
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
