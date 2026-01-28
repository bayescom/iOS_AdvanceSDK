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
#import "AdvanceNativeExpressCommonAdapter.h"

@interface AdvanceNativeExpress () <AdvPolicyServiceDelegate, AdvanceNativeExpressCommonAdapter>
@property (nonatomic, strong) NSArray<AdvSupplier *> *suppliers;

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
    self.suppliers = suppliers;
}

/// 加载某一个渠道对象
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier completion:^{
        // 根据渠道id初始化对应Adapter
        NSString *clsName = [AdvSupplierLoader mappingNativeExpressAdapterClassNameWithSupplierId:supplier.identifier];
        id<AdvanceNativeExpressCommonAdapter> adapter = [[NSClassFromString(clsName) alloc] init];
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
    /// 获取模板信息流广告失败
    if ([_delegate respondsToSelector:@selector(onNativeExpressAdFailToLoad:error:)]) {
        [_delegate onNativeExpressAdFailToLoad:self error:error];
    }
    [self destroyAdapters];
}

// Bidding成功
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
//    self.price = supplier.sdk_price;
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 获取模板信息流广告成功
    if ([_delegate respondsToSelector:@selector(onNativeExpressAdSuccessToLoad:)]) {
        [_delegate onNativeExpressAdSuccessToLoad:self];
    }
    /// 渲染广告
    [self.targetAdapter adapter_render:self.viewController];
}

#pragma mark: - AdvanceNativeExpressCommonAdapter
- (void)nativeAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager setECPMIfNeeded:price supplier:supplier];
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdSuccess error:nil];
}

- (void)nativeAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager checkTargetWithResultfulSupplier:supplier state:AdvSupplierLoadAdFailed error:error];
}

/// 竞胜的渠道广告执行以下回调
- (void)nativeAdapter_didAdRenderSuccessWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper {
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewRenderSuccess:)]) {
        [self.delegate onNativeExpressAdViewRenderSuccess:wrapper];
    }
}

- (void)nativeAdapter_didAdRenderFailWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper error:(NSError *)error {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewRenderFail:error:)]) {
        [self.delegate onNativeExpressAdViewRenderFail:wrapper error:error];
    }
    /// 销毁各渠道Adapter对象
    [self destroyAdapters];
}

- (void)nativeAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventExposed supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewExposured:)]) {
        [self.delegate onNativeExpressAdViewExposured:wrapper];
    }
}

- (void)nativeAdapter_didAdClickedWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper {
    AdvSupplier *supplier = [self getSupplierWithAdapterId:adapterId];
    AdvPolicyService *manager = self.manager;
    [manager reportAdDataWithEventType:AdvSupplierReportTKEventClicked supplier:supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewClicked:)]) {
        [self.delegate onNativeExpressAdViewClicked:wrapper];
    }
}

- (void)nativeAdapter_didAdClosedWithAdapterId:(NSString *)adapterId wrapper:(AdvNativeExpressAdWrapper *)wrapper {
    if ([self.delegate respondsToSelector:@selector(onNativeExpressAdViewClosed:)]) {
        [self.delegate onNativeExpressAdViewClosed:wrapper];
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

- (AdvSupplier *)getSupplierWithAdapterId:(NSString *)adapterId {
    return [self.suppliers adv_filter:^BOOL(AdvSupplier *obj) {
        return [[NSString stringWithFormat:@"%@-%ld",obj.identifier,obj.priority] isEqualToString:adapterId];
    }].firstObject;
}

- (void)dealloc {
   
}

@end
