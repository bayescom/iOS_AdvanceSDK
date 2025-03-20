//
//  GdtInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtInterstitialAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceInterstitial.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface GdtInterstitialAdapter () <GDTUnifiedInterstitialAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GdtInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:_supplier.adspotid];
        _gdt_ad.videoMuted = _adspot.muted;
        _gdt_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_gdt_ad loadAd];
}

- (void)showAd {
    [_gdt_ad presentAdFromRootViewController:_adspot.viewController];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= GdtInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot.manager setECPMIfNeeded:unifiedInterstitial.eCPM supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}


/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/// 插屏广告曝光回调
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 插屏广告点击回调
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
