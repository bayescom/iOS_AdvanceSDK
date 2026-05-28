//
//  AdvanceRewardVideo.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceRewardVideo.h"
#import "AdvConstantHeader.h"
#import "AdvPolicyService.h"
#import "AdvanceCommonAdapter.h"
#import "AdvAdCacheManager.h"
#import "AdvError.h"

@interface AdvanceRewardVideo () <AdvPolicyServiceDelegate, AdvanceCommonRewardVideoAdapterBridge>
@property (nonatomic, strong)ServerReward *serverReward;

@end

@implementation AdvanceRewardVideo

/// 重写父类初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    return [self initWithAdspotId:adspotid extra:extra delegate:nil];
}

/// 便利初始化方法
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra
                        delegate:(id<AdvanceRewardVideoDelegate>)delegate {
    NSMutableDictionary *extraDict = [NSMutableDictionary dictionaryWithDictionary:extra];
    [extraDict adv_safeSetObject:AdvSdkTypeAdNameRewardVideo forKey:AdvSdkTypeAdName];
    
    if (self = [super initWithAdspotId:adspotid extra:extraDict]) {
        self.delegate = delegate;
        self.muted = YES;
    }
    return self;
}


#pragma mark: - AdvPolicyServiceDelegate
/// 广告策略加载成功
- (void)policyServiceLoadSuccessWithModel:(nonnull AdvPolicyModel *)model {
    self.serverReward = model.server_reward;
}

/// 广告策略加载失败
- (void)policyServiceLoadFailedWithError:(nullable NSError *)error {
    /// 获取激励视频广告失败
    if ([_delegate respondsToSelector:@selector(onRewardVideoAdFailToLoad:error:)]) {
        [_delegate onRewardVideoAdFailToLoad:self error:error];
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
        
        id<AdvanceCommonRewardVideoAdapter> adapter;
        // 尝试获取Adapter缓存
        AdvAdCacheModel *cacheModel = [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id];
        if (supplier.enable_cache && cacheModel) { //此次加载允许缓存 且 内存中存在Adapter缓存时，直接回调成功
            adapter = cacheModel.adObject;
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setRewardVideoBridge:self];
            [self rewardVideo_didLoadAdWithAdapter:adapter price:cacheModel.price];
        } else {// 根据渠道id初始化对应Adapter
            NSString *clsName = [AdvSupplierLoader mappingRewardAdapterClassNameWithSupplierId:supplier.identifier];
            adapter = [[NSClassFromString(clsName) alloc] init];
            [self.adapterMap setObject:adapter forKey:supplier.sdk_id];
            [adapter adapter_setRewardVideoBridge:self];
            [adapter adapter_loadAdWithPlacementId:supplier.adspotid config:[self setupAdConfigWithSupplier:supplier]];
        }
    }];
}

// 所有Bidding渠道返回广告失败
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *)error {
    /// 获取激励视频广告失败
    if ([_delegate respondsToSelector:@selector(onRewardVideoAdFailToLoad:error:)]) {
        [_delegate onRewardVideoAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.sdk_id];
    /// 获取激励视频广告成功
    if ([_delegate respondsToSelector:@selector(onRewardVideoAdDidLoad:)]) {
        [_delegate onRewardVideoAdDidLoad:self];
    }
    /// 竞胜通知
    if ([(id<AdvanceCommonRewardVideoAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_sendNotificationWithBidResult:)]) {
        [self.targetAdapter adapter_sendNotificationWithBidResult:bidResult];
    }
}

// 参竞渠道失败
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *)supplier bidResult:(AdvBidWinLossResult * _Nonnull)bidResult {
    id<AdvanceCommonRewardVideoAdapter> adapter = [self.adapterMap objectForKey:supplier.sdk_id];
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
    if ([(id<AdvanceCommonRewardVideoAdapter>)self.targetAdapter respondsToSelector:@selector(adapter_isAdValid)]) {
        valid = [self.targetAdapter adapter_isAdValid];
    }
    if (!valid) {
        [self rewardVideo_failedToShowAdWithAdapter:self.targetAdapter error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - AdvanceCommonRewardVideoAdapterBridge
- (void)rewardVideo_didLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    if (supplier.enable_cache && ![[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) { // 缓存Adapter
        [[AdvAdCacheManager sharedInstance] cacheAdapter:adapter price:price expireTime:supplier.cache_timeout sourceReqId:self.reqId forKey:supplier.sdk_id];
    }
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)rewardVideo_failedToLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)rewardVideo_didAdExposuredWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRewardVideoAdExposured:)]) {
        [self.delegate onRewardVideoAdExposured:self];
    }
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)rewardVideo_failedToShowAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onRewardVideoAdFailToPresent:error:)]) {
        [self.delegate onRewardVideoAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
    /// 删除缓存Adapter
    if ([[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:supplier.sdk_id]) {
        [[AdvAdCacheManager sharedInstance] removeAdCacheModelFromCachedKey:supplier.sdk_id];
    }
}

- (void)rewardVideo_didAdClickedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onRewardVideoAdClicked:)]) {
        [self.delegate onRewardVideoAdClicked:self];
    }
}

- (void)rewardVideo_didAdClosedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onRewardVideoAdClosed:)]) {
        [self.delegate onRewardVideoAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

// 验证激励回调
- (void)rewardVideo_didAdVerifyRewardWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
    AdvPolicyService *manager = self.manager;
    AdvSupplier *supplier = [self getSupplierWithAdapter:adapter];
    
    [manager verifyRewardVideo:self.rewardVideoModel supplier:supplier placementId:self.adspotid completion:^(AdvRewardCallbackInfo * _Nonnull rewardInfo, NSError * _Nonnull error) {
        if (!error) {
            if ([self.delegate respondsToSelector:@selector(onRewardVideoAdDidRewardSuccess:rewardInfo:)]) {
                [self.delegate onRewardVideoAdDidRewardSuccess:self rewardInfo:rewardInfo];
            }
        } else {
            if ([self.delegate respondsToSelector:@selector(onRewardVideoAdDidServerRewardFail:error:)]) {
                [self.delegate onRewardVideoAdDidServerRewardFail:self error:error];
            }
        }
    }];
}

- (void)rewardVideo_didAdPlayFinishWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
    if ([self.delegate respondsToSelector:@selector(onRewardVideoAdDidPlayFinish:)]) {
        [self.delegate onRewardVideoAdDidPlayFinish:self];
    }
}


#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:@(self.muted) forKey:kAdvanceAdVideoMutedKey];
    [config adv_safeSetObject:supplier.mediaid forKey:kAdvanceSupplierMediaIdKey];
    [config adv_safeSetObject:self.rewardVideoModel forKey:kAdvanceRewardVideoModelKey];
    [config adv_safeSetObject:self.serverReward.name forKey:kAdvanceServerRewardNameKey];
    [config adv_safeSetObject:@(self.serverReward.count) forKey:kAdvanceServerRewardCountKey];
    return config.copy;
}

- (AdvSupplier *)getSupplierWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter {
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

