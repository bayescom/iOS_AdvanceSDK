//
//  AdvSigmobInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvSigmobInterstitialAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvSigmobInterstitialAdapter () <WindNewIntersititialAdDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) WindNewIntersititialAd *sigmob_ad;

@end

@implementation AdvSigmobInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindNewIntersititialAd alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
    [_sigmob_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_sigmob_ad showAdFromRootViewController:rootViewController options:nil];
}

- (BOOL)adapter_isAdValid {
    return _sigmob_ad.ready;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    
}


#pragma mark - WindNewIntersititialAdDelegate
- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd {
    [self.bridge interstitial_didLoadAdWithAdapter:self price:intersititialAd.getEcpm.integerValue];
}

- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd didFailWithError:(NSError *)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)intersititialAdDidVisible:(WindNewIntersititialAd *)intersititialAd {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)intersititialAdDidShowFailed:(WindNewIntersititialAd *)intersititialAd error:(NSError *)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)intersititialAdDidClick:(WindNewIntersititialAd *)intersititialAd {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)intersititialAdDidClose:(WindNewIntersititialAd *)intersititialAd {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

@end
