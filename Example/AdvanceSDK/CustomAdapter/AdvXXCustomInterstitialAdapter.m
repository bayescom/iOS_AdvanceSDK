//
//  AdvXXCustomInterstitialAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/8.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomInterstitialAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvanceCommonAdapter.h>
#import <AdvanceSDK/AdvAdConfigHeader.h>

@interface AdvXXCustomInterstitialAdapter () <BUNativeExpressFullscreenVideoAdDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *interstitialAd;

@end

@implementation AdvXXCustomInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _interstitialAd = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:placementId];
    _interstitialAd.delegate = self;
    [_interstitialAd loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_interstitialAd showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_interstitialAd win:@(result.secondPrice)];
    } else {
        [_interstitialAd loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}

#pragma mark: - BUNativeExpressFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    [self.bridge interstitial_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
