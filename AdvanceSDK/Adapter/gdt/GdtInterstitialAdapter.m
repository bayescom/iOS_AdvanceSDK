//
//  GdtInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtInterstitialAdapter.h"

#if __has_include(<GDTUnifiedInterstitialAd.h>)
#import <GDTUnifiedInterstitialAd.h>
#else
#import "GDTUnifiedInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"

@interface GdtInterstitialAdapter () <GDTUnifiedInterstitialAdDelegate>
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceInterstitial *adspot;

@end

@implementation GdtInterstitialAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:_adspot.currentSdkSupplier.adspotid];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd];
}

- (void)showAd {
    [_gdt_ad presentAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}


// MARK: ======================= GdtInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdReceived)]) {
        [self.delegate advanceInterstitialOnAdReceived];
    }
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnReadyToShow)]) {
        [self.delegate advanceInterstitialOnReadyToShow];
    }
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _gdt_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceInterstitialOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 插屏广告曝光回调
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdShow)]) {
        [self.delegate advanceInterstitialOnAdShow];
    }
}

/// 插屏广告点击回调
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClicked)]) {
        [self.delegate advanceInterstitialOnAdClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClosed)]) {
        [self.delegate advanceInterstitialOnAdClosed];
    }
}

@end
