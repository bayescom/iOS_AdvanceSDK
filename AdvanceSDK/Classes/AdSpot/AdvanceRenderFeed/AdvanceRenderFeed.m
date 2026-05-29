//
//  AdvanceRenderFeed.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvanceRenderFeed.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"

@interface AdvanceRenderFeed () <AdvPolicyServiceDelegate, AdvanceCommonRenderFeedAdapterBridge>

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
    [self.suppliers addObjectsFromArray:suppliers];
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier completion:^{
        AdvPolicyService *manager = self.manager;
        [manager reportAdDataWithEventType:AdvSupplierReportTKEventLoadEnd supplier:supplier error:nil];
        
        id<AdvanceCommonRenderFeedAdapter> adapter;
        // 尝试获取Adapter缓存
        AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
        if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
            adapter = cacheModel.adObject;
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setRenderFeedBridge:self]; // 现有的adapter实现方式，在更新bridge的时候，所属的AdView未及时更新bridge导致后续回调中断。
            [self renderFeed_didLoadAdWithAdapter:adapter price:cacheModel.price];
        } else {// 根据渠道id初始化对应Adapter
            NSString *clsName = [AdvSupplierLoader mappingRenderFeedAdapterClassNameWithSupplierId:supplier.identifier];
            adapter = [[NSClassFromString(clsName) alloc] init];
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setRenderFeedBridge:self];
            [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
        }
    }];
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取模板信息流广告失败
    if ([_delegate respondsToSelector:@selector(onRenderFeedAdFailToLoad:error:)]) {
        [_delegate onRenderFeedAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    
    /// 获取广告包装类信息
    AdvRenderFeedAdWrapper *feedAdWrapper = [self.targetAdapter adapter_renderFeedAdWrapper];
    /// 获取模板信息流广告成功
    if ([_delegate respondsToSelector:@selector(onRenderFeedAdSuccessToLoad:feedAdWrapper:)]) {
        [_delegate onRenderFeedAdSuccessToLoad:self feedAdWrapper:feedAdWrapper];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonRenderFeedAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonRenderFeedAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
    if ([adapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [adapter adapter_sendNotificationWithBidResult:bidResult];
    }
}


#pragma mark: - AdvanceCommonRenderFeedAdapterBridge
- (void)renderFeed_didLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    /// 先不做缓存，有bug详见上述细节
//    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
//        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
//    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)renderFeed_failedToLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)renderFeed_didAdExposuredWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewExposured:)]) {
        [self.delegate onRenderFeedAdViewExposured:self];
    }
    /// 删除缓存Adapter
//    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
//        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
//    }
}

- (void)renderFeed_didAdClickedWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewClicked:)]) {
        [self.delegate onRenderFeedAdViewClicked:self];
    }
}

- (void)renderFeed_didAdClosedWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdViewClosed:)]) {
        [self.delegate onRenderFeedAdViewClosed:self];
    }
}

- (void)renderFeed_didAdClosedDetailPageWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdDidCloseDetailPage:)]) {
        [self.delegate onRenderFeedAdDidCloseDetailPage:self];
    }
}

- (void)renderFeed_didAdPlayFinishWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onRenderFeedAdDidPlayFinish:)]) {
        [self.delegate onRenderFeedAdDidPlayFinish:self];
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

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter {
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
