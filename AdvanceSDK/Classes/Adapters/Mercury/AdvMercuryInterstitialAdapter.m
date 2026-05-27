//
//  AdvMercuryInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryInterstitialAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvMercuryInterstitialAdapter () <MercuryInterstitialAdDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) MercuryInterstitialAd *mercury_ad;

@end

@implementation AdvMercuryInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _mercury_ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:placementId delegate:self];
    [_mercury_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_mercury_ad presentAdFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _mercury_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [_mercury_ad sendLossNotificationWithPrice:result.winPrice];
    }
}


#pragma mark: - MercuryInterstitialAdDelegate
- (void)mercury_interstitialSuccessToLoadAd:(MercuryInterstitialAd *)interstitialAd  {
    [self.bridge interstitial_didLoadAdWithAdapter:self price:interstitialAd.price];
}

- (void)mercury_interstitialFailToLoadAd:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)mercury_interstitialRenderFail:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)mercury_interstitialDidPresentScreen:(MercuryInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)mercury_interstitialClicked:(MercuryInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)mercury_interstitialDidDismissScreen:(MercuryInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
