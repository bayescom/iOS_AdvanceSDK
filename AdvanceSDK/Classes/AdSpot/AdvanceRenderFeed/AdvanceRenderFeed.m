//
//  AdvanceRenderFeed.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceRenderFeed.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceRenderFeedCommonAdapter.h"

@interface AdvanceRenderFeed () <AdvPolicyServiceDelegate, AdvanceRenderFeedCommonAdapter>
@property (nonatomic, strong) NSArray<AdvSupplier *> *suppliers;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvanceRenderFeed

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceRenderFeedDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameRenderFeed forKey:AdvSdkTypeAdName];
    
    if (self = [super initWithAdspotId:adspotid extra:extraDict]) {
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
    /// 获取模板信息流广告失败
    if ([_delegate respondsToSelector:@selector(onRenderFeedAdFailToLoad:error:)]) {
        [_delegate onRenderFeedAdFailToLoad:self error:error];
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
        NSString *clsName = [AdvSupplierLoader mappingRenderFeedAdapterClassNameWithSupplierId:supplier.identifier];
        id<AdvanceRenderFeedCommonAdapter> adapter = [[NSClassFromString(clsName) alloc] init];
        if (adapter) {
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setupWithAdapterId:supplier.sdk_id placementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
            adapter.delegate = self;
            [adapter adapter_loadAd];
        }
    }];
}

// Bidding失败（渠道广告全部加载失败）
- (void)policyServiceFailedBiddingWithError:(NSError *)error description:(NSDictionary * _Nullable)description {
    AdvLog(@"渠道广告全部加载失败：%@", description);
    /// 获取模板信息流广告失败
    if ([_delegate respondsToSelector:@selector(onRenderFeedAdFailToLoad:error:)]) {
        [_delegate onRenderFeedAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取广告包装类信息
    self.feedAdWrapper = [self.targetAdapter adapter_renderFeedAdWrapper];
    /// 获取模板信息流广告成功
    if ([_delegate respondsToSelector:@selector(onRenderFeedAdSuccessToLoad:feedAdWrapper:)]) {
        [_delegate onRenderFeedAdSuccessToLoad:self feedAdWrapper:self.feedAdWrapper];
    }
}

#pragma mark: - AdvanceNativeExpressCommonAdapter
- (void)renderAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)renderAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)renderAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewExposured:)]) {
        [self.delegate onRenderFeedAdViewExposured:self.feedAdWrapper];
    }
}

- (void)renderAdapter_didAdClickedWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewClicked:)]) {
        [self.delegate onRenderFeedAdViewClicked:self.feedAdWrapper];
    }
}

- (void)renderAdapter_didAdClosedWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewClosed:)]) {
        [self.delegate onRenderFeedAdViewClosed:self.feedAdWrapper];
    }
}

- (void)renderAdapter_didAdClosedDetailPageWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdDidCloseDetailPage:)]) {
        [self.delegate onRenderFeedAdDidCloseDetailPage:self.feedAdWrapper];
    }
}

- (void)renderAdapter_didAdPlayFinishWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdDidPlayFinish:)]) {
        [self.delegate onRenderFeedAdDidPlayFinish:self.feedAdWrapper];
    }
}

#pragma mark: - load
- (void)loadAd {
    [super loadAdPolicy];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    [config adv_safeSetObject:self.viewController forKey:kAdvanceAdPresentControllerKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapterId:(NSString *)adapterId {
    return [self.suppliers adv_filter:^BOOL(AdvSupplier *obj) {
        return [obj.sdk_id isEqualToString:adapterId];
    }].firstObject;
}

- (void)dealloc {
    
}

@end
