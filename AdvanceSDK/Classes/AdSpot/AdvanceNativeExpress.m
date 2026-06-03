//
//  AdvanceNativeExpress.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceNativeExpress.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"

@interface AdvanceNativeExpress () <AdvPolicyServiceDelegate, AdvanceCommonNativeExpressAdapterBridge>

@end

@implementation AdvanceNativeExpress

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceNativeExpressDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameNativeExpress forKey:AdvSdkTypeAdName];
    
    if (self = [super initWithAdspotId:adspotid extra:extraDict]) {
        self.delegate = delegate;
        self.muted = YES;
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
    if ([_delegate respondsToSelector:@selector(onNativeExpressAdFailToLoad:error:)]) {
        [_delegate onNativeExpressAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// 开始Bidding
- (void)policyServiceStartBiddingWithSuppliers:(NSArray <AdvSupplier *> *_Nullable)suppliers {
    [self.suppliers addObjectsFromArray:suppliers];
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    id<AdvanceCommonNativeExpressAdapter> adapter;
    // 尝试获取Adapter缓存
    AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
    if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
        supplier.cachedReqId = cacheModel.sourceReqId; //用于tk上报
        adapter = cacheModel.adObject;
        [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setNativeExpressBridge:self];
        [self nativeExpress_didLoadAdWithAdapter:adapter price:cacheModel.price];
    } else {// 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingNativeExpressAdapterNameWithSupplierId:supplier.identifier];
        adapter = [[NSClassFromString(clsName) alloc] init];
        [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setNativeExpressBridge:self];
        [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
    }
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取模板信息流广告失败
    if ([_delegate respondsToSelector:@selector(onNativeExpressAdFailToLoad:error:)]) {
        [_delegate onNativeExpressAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取模板信息流广告成功
    if ([_delegate respondsToSelector:@selector(onNativeExpressAdSuccessToLoad:)]) {
        [_delegate onNativeExpressAdSuccessToLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonNativeExpressAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
    /// 渲染广告并设置控制器
    if ([(id<AdvanceCommonNativeExpressAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_renderAd:)]) {
        [self.targetAdapter adapter_renderAd:self.viewController];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonNativeExpressAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
    if ([adapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [adapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

#pragma mark: - AdvanceCommonNativeExpressAdapterBridge
- (void)nativeExpress_didLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)nativeExpress_failedToLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)nativeExpress_didAdRenderSuccessWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewRenderSuccess:)]) {
        [self.delegate onNativeExpressAdViewRenderSuccess:expressView];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)nativeExpress_didAdRenderFailWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewRenderFail:error:)]) {
        [self.delegate onNativeExpressAdViewRenderFail:expressView error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)nativeExpress_didAdExposuredWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewExposured:)]) {
        [self.delegate onNativeExpressAdViewExposured:expressView];
    }
}

- (void)nativeExpress_didAdClickedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewClicked:)]) {
        [self.delegate onNativeExpressAdViewClicked:expressView];
    }
}

- (void)nativeExpress_didAdClosedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView {
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewClosed:)]) {
        [self.delegate onNativeExpressAdViewClosed:expressView];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}


#pragma mark: - load
- (void)loadAd {
    [super loadAdPolicy];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:@(self.muted) forKey:kAdvanceAdVideoMutedKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    [config adv_safeSetObject:@(self.adSize) forKey:kAdvanceAdSizeKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter {
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
