//
//  AdvFunlinkInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkInterstitialAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvFunlinkInterstitialAdapter () <FLinkInterstitialDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) FLinkInterstitialManager *flink_ad;

@end

@implementation AdvFunlinkInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkInterstitialManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    [_flink_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    _flink_ad.showAdController = rootViewController;
    [_flink_ad showInterstitialAd];
}

- (BOOL)adapter_isAdValid {
    return _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_flink_ad sendWinNotificationWithPrice:result.secondPrice];
    } else {
        [_flink_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - FLinkInterstitialDelegate
- (void)interstitialAdDidLoad  {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge interstitial_didLoadAdWithAdapter:self price:ecpm];
}

- (void)interstitialAdDidFailed:(NSError *)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)interstitialAdDidVisible {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)interstitialAdDidClick {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)interstitialAdDidAutoClose:(BOOL)autoClose {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
