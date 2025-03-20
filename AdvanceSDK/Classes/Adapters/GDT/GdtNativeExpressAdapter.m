//
//  GdtNativeExpressAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtNativeExpressAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvanceAdapter.h"

@interface GdtNativeExpressAdapter () <GDTNativeExpressAdDelegete, AdvanceAdapter>
@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation GdtNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTNativeExpressAd alloc] initWithPlacementId:_supplier.adspotid
                                                           adSize:_adspot.adSize];
        _gdt_ad.videoMuted = _adspot.muted;
        _gdt_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_gdt_ad loadAd:1];
}

- (void)winnerAdapterToShowAd {
    /// 广告加载成功回调
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
    
    /// 渲染广告
    if (!_adspot.isGroMoreADN) {
        [self renderNativeAdView];
    }
}

/// 渲染广告
- (void)renderNativeAdView {
    [self.nativeAds enumerateObjectsUsingBlock:^(__kindof AdvanceNativeExpressAd * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj.expressView;
        expressView.controller = self.adspot.viewController;
        [expressView render];
    }];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= GDTNativeExpressAdDelegete =======================
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (!views.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"GDTAdErrorDomain" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }

    self.nativeAds = [NSMutableArray array];
    for (GDTNativeExpressAdView *view in views) {
        AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
        TT.expressView = view;
        TT.identifier = _supplier.identifier;
        [self.nativeAds addObject:TT];
    }
    
    [self.adspot.manager setECPMIfNeeded:views.firstObject.eCPM supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}


- (AdvanceNativeExpressAd *)getNativeExpressAdWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.nativeAds.count; i++) {
        AdvanceNativeExpressAd *temp = self.nativeAds[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}

@end
