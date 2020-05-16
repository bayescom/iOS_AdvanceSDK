//
//  GdtFullScreenVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtFullScreenVideoAdapter.h"

#if __has_include(<GDTUnifiedInterstitialAd.h>)
#import <GDTUnifiedInterstitialAd.h>
#else
#import "GDTUnifiedInterstitialAd.h"
#endif

#import "AdvanceFullScreenVideo.h"

@interface GdtFullScreenVideoAdapter () <GDTUnifiedInterstitialAdDelegate>
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;

@end

@implementation GdtFullScreenVideoAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceFullScreenVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:_adspot.currentSdkSupplier.adspotid];
    _gdt_ad.delegate = self;
    [_gdt_ad loadFullScreenAd];
}

- (void)showAd {
    [_gdt_ad presentFullScreenAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}


// MARK: ======================= GDTUnifiedInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdReceived)]) {
        [self.delegate advanceFullScreenVideoOnAdReceived];
    }
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _gdt_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 插屏广告曝光回调
- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdShow)]) {
        [self.delegate advanceFullScreenVideoOnAdShow];
    }
}

/// 插屏广告点击回调
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdClicked)]) {
        [self.delegate advanceFullScreenVideoOnAdClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdClosed)]) {
        [self.delegate advanceFullScreenVideoOnAdClosed];
    }
}

/// 视频播放状态发生改变
- (void)unifiedInterstitialAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status {
    if (status == GDTMediaPlayerStatusStoped) {
        if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdPlayFinish)]) {
            [self.delegate advanceFullScreenVideoOnAdPlayFinish];
        }
    }
}

@end
