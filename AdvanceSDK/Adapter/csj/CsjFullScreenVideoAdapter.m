//
//  CsjFullScreenVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjFullScreenVideoAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceFullScreenVideo.h"

@interface CsjFullScreenVideoAdapter () <BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;

@end

@implementation CsjFullScreenVideoAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceFullScreenVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid];
    _csj_ad.delegate = self;
    [_csj_ad loadAdData];
}

- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}


// MARK: ======================= BUNativeExpressFullscreenVideoAdDelegate =======================
/// 广告预加载成功回调
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdReceived)]) {
        [self.delegate advanceFullScreenVideoOnAdReceived];
    }
}

/// 广告预加载失败回调
- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 渲染失败
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 广告曝光回调
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdShow)]) {
        [self.delegate advanceFullScreenVideoOnAdShow];
    }
}

/// 广告点击回调
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdClicked)]) {
        [self.delegate advanceFullScreenVideoOnAdClicked];
    }
}

/// 广告曝光结束回调
- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdClosed)]) {
        [self.delegate advanceFullScreenVideoOnAdClosed];
    }
}

/// 广告播放结束
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdPlayFinish)]) {
            [self.delegate advanceFullScreenVideoOnAdPlayFinish];
        }
    }
}

@end
