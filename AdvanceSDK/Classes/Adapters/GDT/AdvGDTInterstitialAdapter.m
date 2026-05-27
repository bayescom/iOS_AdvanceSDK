//
//  AdvGDTInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTInterstitialAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvGDTInterstitialAdapter () <GDTUnifiedInterstitialAdDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;

@end

@implementation AdvGDTInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:placementId];
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_gdt_ad presentAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _gdt_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_gdt_ad sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [_gdt_ad sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}


#pragma mark: - GDTUnifiedInterstitialAdDelegate
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.bridge interstitial_didLoadAdWithAdapter:self price:unifiedInterstitial.eCPM];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

/// 渲染失败
- (void)unifiedInterstitialRenderFail:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

/// 展示失败
- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
