//
//  AdvanceFullScreenVideo.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceFullScreenVideo.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"

@interface AdvanceFullScreenVideo () <AdvPolicyServiceDelegate, AdvanceCommonFullscreenVideoAdapterBridge>

@end

@implementation AdvanceFullScreenVideo

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceFullScreenVideoDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameFullScreenVideo forKey:AdvSdkTypeAdName];
    
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
    /// 获取全屏视频广告失败
    if ([_delegate respondsToSelector:@selector(onFullScreenVideoAdFailToLoad:error:)]) {
        [_delegate onFullScreenVideoAdFailToLoad:self error:error];
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
        
        id<AdvanceCommonFullscreenVideoAdapter> adapter;
        // 尝试获取Adapter缓存
        AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
        if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
            adapter = cacheModel.adObject;
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setFullscreenBridge:self];
            [self fullscreen_didLoadAdWithAdapter:adapter price:cacheModel.price];
        } else {// 根据渠道id初始化对应Adapter
            NSString *clsName = [AdvSupplierLoader mappingFullScreenAdapterClassNameWithSupplierId:supplier.identifier];
            adapter = [[NSClassFromString(clsName) alloc] init];
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setFullscreenBridge:self];
            [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
        }
    }];
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取全屏视频广告失败
    if ([_delegate respondsToSelector:@selector(onFullScreenVideoAdFailToLoad:error:)]) {
        [_delegate onFullScreenVideoAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取全屏视频广告成功
    if ([_delegate respondsToSelector:@selector(onFullScreenVideoAdDidLoad:)]) {
        [_delegate onFullScreenVideoAdDidLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonFullscreenVideoAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonFullscreenVideoAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
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
    if ([(id<AdvanceCommonFullscreenVideoAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        valid = [self.targetAdapter adapter_isAdValid];
    }
    if (!valid) {
        [self fullscreen_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - AdvanceCommonFullscreenVideoAdapterBridge
- (void)fullscreen_didLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)fullscreen_failedToLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)fullscreen_didAdExposuredWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdExposured:)]) {
        [self.delegate onFullScreenVideoAdExposured:self];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)fullscreen_failedToShowAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdFailToPresent:error:)]) {
        [self.delegate onFullScreenVideoAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)fullscreen_didAdClickedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdClicked:)]) {
        [self.delegate onFullScreenVideoAdClicked:self];
    }
}

- (void)fullscreen_didAdClosedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdClosed:)]) {
        [self.delegate onFullScreenVideoAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)fullscreen_didAdPlayFinishWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdDidPlayFinish:)]) {
        [self.delegate onFullScreenVideoAdDidPlayFinish:self];
    }
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:@(self.muted) forKey:kAdvanceAdVideoMutedKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter {
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
