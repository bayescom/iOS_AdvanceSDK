
#import "AdvanceSplash.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceSplashCommonAdapter.h"

@interface AdvanceSplash () <AdvPolicyServiceDelegate, AdvanceSplashCommonAdapter>
@property (nonatomic, strong) NSArray<AdvSupplier *> *suppliers;

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
    self.suppliers = suppliers;
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier completion:^{
        AdvPolicyService *manager = self.manager;
        [manager reportAdDataWithEventType:AdvSupplierReportTKEventLoadEnd supplier:supplier error:nil];
        // 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingSplashAdapterClassNameWithSupplierId:supplier.identifier];
        id<AdvanceSplashCommonAdapter> adapter = [[NSClassFromString(clsName) alloc] init];
        if (adapter) {
            [self.adapterMap setObject:adapter forKey:supplier.supplierKey];
            [adapter adapter_setupWithAdapterId:supplier.supplierKey placementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
            adapter.delegate = self;
            [adapter adapter_loadAd];
        }
    }];
}

// Bidding失败（渠道广告全部加载失败）
- (void)policyServiceFailedBiddingWithError:(NSError *)error description:(NSDictionary * _Nullable)description {
    AdvLog(@"渠道广告全部加载失败：%@", description);
    /// 获取开屏广告失败
    if ([_delegate respondsToSelector:@selector(onSplashAdFailToLoad:error:)]) {
        [_delegate onSplashAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 获取开屏广告成功
    if ([_delegate respondsToSelector:@selector(onSplashAdDidLoad:)]) {
        [_delegate onSplashAdDidLoad:self];
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
    return [self.targetAdapter adapter_isAdValid];
}

#pragma mark: - AdvanceSplashCommonAdapter
- (void)splashAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)splashAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)splashAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onSplashAdExposured:)]) {
        [self.delegate onSplashAdExposured:self];
    }
}

- (void)splashAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onSplashAdFailToPresent:error:)]) {
        [self.delegate onSplashAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)splashAdapter_didAdClickedWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onSplashAdClicked:)]) {
        [self.delegate onSplashAdClicked:self];
    }
}

- (void)splashAdapter_didAdClosedWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onSplashAdClosed:)]) {
        [self.delegate onSplashAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:self.viewController forKey:kAdvanceAdPresentControllerKey];
    [config adv_safeSetObject:self.bottomLogoView forKey:kAdvanceSplashBottomViewKey];
    [config adv_safeSetObject:@(supplier.timeout) forKey:kAdvanceAdLoadTimeoutKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapterId:(NSString *)adapterId {
    return [self.suppliers adv_filter:^BOOL(AdvSupplier *obj) {
        return [[NSString stringWithFormat:@"%@-%ld",obj.identifier,obj.priority] isEqualToString:adapterId];
    }].firstObject;
}

- (void)dealloc {
   
}

@end
