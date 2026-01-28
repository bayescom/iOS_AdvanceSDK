//
//  AdvanceBanner.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBanner.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceBannerCommonAdapter.h"

@interface AdvanceBanner () <AdvPolicyServiceDelegate, AdvanceBannerCommonAdapter>
@property (nonatomic, strong) NSArray<AdvSupplier *> *suppliers;

@end

@implementation AdvanceBanner

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceBannerDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameBanner forKey:AdvSdkTypeAdName];
    
    if (self = [super initWithAdspotId:adspotid extra:extraDict.copy]) {
        self.delegate = delegate;
//        self.refreshInterval = MAXINTERP;
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
    if ([_delegate respondsToSelector:@selector(onBannerAdFailToLoad:error:)]) {
        [_delegate onBannerAdFailToLoad:self error:error];
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
        // 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingBannerAdapterClassNameWithSupplierId:supplier.identifier];
        id<AdvanceBannerCommonAdapter> adapter = [[NSClassFromString(clsName) alloc] init];
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
    if ([_delegate respondsToSelector:@selector(onBannerAdFailToLoad:error:)]) {
        [_delegate onBannerAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
    //self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 获取开屏广告成功
    if ([_delegate respondsToSelector:@selector(onBannerAdDidLoad:)]) {
        [_delegate onBannerAdDidLoad:self];
    }
}

#pragma mark: - load
- (void)loadAd {
    [super loadAdPolicy];
}

- (BOOL)isAdValid {
    return [self.targetAdapter adapter_isAdValid];
}

- (UIView *)bannerView {
    return [self.targetAdapter adapter_bannerView];
}

#pragma mark: - AdvanceBannerCommonAdapter
- (void)bannerAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)bannerAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)bannerAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onBannerAdExposured:)]) {
        [self.delegate onBannerAdExposured:self];
    }
}

- (void)bannerAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onBannerAdFailToPresent:error:)]) {
        [self.delegate onBannerAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)bannerAdapter_didAdClickedWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onBannerAdClicked:)]) {
        [self.delegate onBannerAdClicked:self];
    }
}

- (void)bannerAdapter_didAdClosedWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onBannerAdClosed:)]) {
        [self.delegate onBannerAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:self.viewController forKey:kAdvanceAdPresentControllerKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
//    [config adv_safeSetObject:@(self.refreshInterval) forKey:kAdvanceBannerRefreshIntervalKey];
    [config adv_safeSetObject:@(self.adSize) forKey:kAdvanceAdSizeKey];
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
