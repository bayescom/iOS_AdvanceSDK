//
//  AdvanceInterstitial.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceInterstitial.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"

@interface AdvanceInterstitial () <AdvPolicyServiceDelegate, AdvanceCommonInterstitialAdapterBridge>

@end

@implementation AdvanceInterstitial

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceInterstitialDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameInterstitial forKey:AdvSdkTypeAdName];
    
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
    /// 获取插屏广告失败
    if ([_delegate respondsToSelector:@selector(onInterstitialAdFailToLoad:error:)]) {
        [_delegate onInterstitialAdFailToLoad:self error:error];
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
        
        id<AdvanceCommonInterstitialAdapter> adapter;
        // 尝试获取Adapter缓存
        AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
        if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
            adapter = cacheModel.adObject;
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setInterstitialBridge:self];
            [self interstitial_didLoadAdWithAdapter:adapter price:cacheModel.price];
        } else {// 根据渠道id初始化对应Adapter
            NSString *clsName = [AdvSupplierLoader mappingInterstitialAdapterClassNameWithSupplierId:supplier.identifier];
            adapter = [[NSClassFromString(clsName) alloc] init];
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setInterstitialBridge:self];
            [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
        }
    }];
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取插屏广告失败
    if ([_delegate respondsToSelector:@selector(onInterstitialAdFailToLoad:error:)]) {
        [_delegate onInterstitialAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取插屏广告成功
    if ([_delegate respondsToSelector:@selector(onInterstitialAdDidLoad:)]) {
        [_delegate onInterstitialAdDidLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonInterstitialAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonInterstitialAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
    if ([adapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [adapter adapter_sendNotificationWithBidResult:bidResult];
    }
}


#pragma mark: - load & show
- (void)loadAd {
    [super loadAdPolicy];
}

- (void)showAdFromViewController:(UIViewController *)viewController {
    if (![self isAdValid]) {
        return;
    }
    [self.targetAdapter adapter_showAdFromRootViewController:viewController];
}

- (BOOL)isAdValid {
    BOOL valid = YES;
    if ([(id<AdvanceCommonInterstitialAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        valid = [self.targetAdapter adapter_isAdValid];
    }
    if (!valid) {
        [self interstitial_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - AdvanceCommonInterstitialAdapterBridge
- (void)interstitial_didLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)interstitial_failedToLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)interstitial_didAdExposuredWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onInterstitialAdExposured:)]) {
        [self.delegate onInterstitialAdExposured:self];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)interstitial_failedToShowAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onInterstitialAdFailToPresent:error:)]) {
        [self.delegate onInterstitialAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)interstitial_didAdClickedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onInterstitialAdClicked:)]) {
        [self.delegate onInterstitialAdClicked:self];
    }
}

- (void)interstitial_didAdClosedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onInterstitialAdClosed:)]) {
        [self.delegate onInterstitialAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:@(self.muted) forKey:kAdvanceAdVideoMutedKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter {
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
