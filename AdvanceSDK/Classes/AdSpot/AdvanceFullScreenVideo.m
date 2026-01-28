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
#import "AdvanceFullScreenVideoCommonAdapter.h"

@interface AdvanceFullScreenVideo () <AdvPolicyServiceDelegate, AdvanceFullScreenVideoCommonAdapter>
@property (nonatomic, strong) NSArray<AdvSupplier *> *suppliers;

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
    self.suppliers = suppliers;
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier completion:^{
        // 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingFullScreenAdapterClassNameWithSupplierId:supplier.identifier];
        id<AdvanceFullScreenVideoCommonAdapter> adapter = [[NSClassFromString(clsName) alloc] init];
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
    /// 获取全屏视频广告失败
    if ([_delegate respondsToSelector:@selector(onFullScreenVideoAdFailToLoad:error:)]) {
        [_delegate onFullScreenVideoAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 获取全屏视频广告成功
    if ([_delegate respondsToSelector:@selector(onFullScreenVideoAdDidLoad:)]) {
        [_delegate onFullScreenVideoAdDidLoad:self];
    }
}


#pragma mark: - AdvanceFullScreenVideoCommonAdapter
- (void)fullscreenAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)fullscreenAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)fullscreenAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdExposured:)]) {
        [self.delegate onFullScreenVideoAdExposured:self];
    }
}

- (void)fullscreenAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdFailToPresent:error:)]) {
        [self.delegate onFullScreenVideoAdFailToPresent:self error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)fullscreenAdapter_didAdClickedWithAdapterId:(NSString *)adapterId {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdClicked:)]) {
        [self.delegate onFullScreenVideoAdClicked:self];
    }
}

- (void)fullscreenAdapter_didAdClosedWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdClosed:)]) {
        [self.delegate onFullScreenVideoAdClosed:self];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)fullscreenAdapter_didAdPlayFinishWithAdapterId:(NSString *)adapterId {
    if ([self.delegate respondsToSelector:@selector(onFullScreenVideoAdDidPlayFinish:)]) {
        [self.delegate onFullScreenVideoAdDidPlayFinish:self];
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
    return [self.targetAdapter adapter_isAdValid];
}

#pragma mark: - setting
- (NSDictionary *)setupAdConfigWithSupplier:(AdvSupplier *)supplier {
    NSMutableDictionary *config = [NSMutableDictionary dictionary];
    [config adv_safeSetObject:@(self.muted) forKey:kAdvanceAdVideoMutedKey];
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
