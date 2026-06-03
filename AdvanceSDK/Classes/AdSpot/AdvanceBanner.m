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
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"

@interface AdvanceBanner () <AdvPolicyServiceDelegate, AdvanceCommonBannerAdapterBridge>

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
    [self.suppliers addObjectsFromArray:suppliers];
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    id<AdvanceCommonBannerAdapter> adapter;
    // 尝试获取Adapter缓存
    AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
    if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
        supplier.cachedReqId = cacheModel.sourceReqId; //用于tk上报
        adapter = cacheModel.adObject;
        [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setBannerBridge:self];
        [self banner_didLoadAdWithAdapter:adapter price:cacheModel.price];
    } else {// 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingBannerAdapterNameWithSupplierId:supplier.identifier];
        adapter = [[NSClassFromString(clsName) alloc] init];
        [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
        [adapter adapter_setBannerBridge:self];
        [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
    }
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取开屏广告失败
    if ([_delegate respondsToSelector:@selector(onBannerAdFailToLoad:error:)]) {
        [_delegate onBannerAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    //self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取开屏广告成功
    if ([_delegate respondsToSelector:@selector(onBannerAdDidLoad:)]) {
        [_delegate onBannerAdDidLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonBannerAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonBannerAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
    if ([adapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [adapter adapter_sendNotificationWithBidResult:bidResult];
    }
}


#pragma mark: - load
- (void)loadAd {
    [super loadAdPolicy];
}

- (BOOL)isAdValid {
    BOOL valid = YES;
    if ([(id<AdvanceCommonBannerAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        valid = [self.targetAdapter adapter_isAdValid];
    }
    if (!valid) {
        [self banner_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (UIView *)bannerView {
    if ([(id<AdvanceCommonBannerAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_bannerView)]) {
        return [self.targetAdapter adapter_bannerView];
    }
    return nil;
}

#pragma mark: - AdvanceCommonBannerAdapterBridge
- (void)banner_didLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)banner_failedToLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)banner_didAdExposuredWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onBannerAdExposured:)]) {
        [self.delegate onBannerAdExposured:self];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)banner_failedToShowAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onBannerAdFailToPresent:error:)]) {
        [self.delegate onBannerAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)banner_didAdClickedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onBannerAdClicked:)]) {
        [self.delegate onBannerAdClicked:self];
    }
}

- (void)banner_didAdClosedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {
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

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter {
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
