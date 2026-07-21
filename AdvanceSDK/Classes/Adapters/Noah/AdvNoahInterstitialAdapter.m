//
//  AdvNoahInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahInterstitialAdapter.h"
#import <NoahSDK/NoahSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvNoahInterstitialAdapter () <NAInterstitialAdListener, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) NAInterstitialAd *noah_ad;

@end

@implementation AdvNoahInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    RequestInfo *requestInfo = [[RequestInfo alloc] init];
    requestInfo.slotKey = placementId;
    [NAInterstitialAd loadAdWithReqInfo:requestInfo adDelegate:self];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_noah_ad showAdInViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _noah_ad.isValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_noah_ad sendWinNotification:result.secondPrice];
    } else {
        [_noah_ad sendLossNotification:result.winPrice reason:0];
    }
}


#pragma mark: - NAInterstitialAdListener
- (void)onInterstitialAdLoaded:(NAInterstitialAd *)ad {
    self.noah_ad = ad;
    [self.bridge interstitial_didLoadAdWithAdapter:self price:ad.price];
}

- (void)onInterstitialAdLoadFail:(RequestInfo *)reqInfo error:(AdError *)error {
    NSError *err = [NSError errorWithDomain:@"NoahAdErrorDomain" code:[error getErrorCode] userInfo:@{NSLocalizedDescriptionKey: [error getErrorMessage] ?: @""}];
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:err];
}

- (void)onInterstitialAdShown:(NAInterstitialAd *)ad {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)onInterstitialAdClicked:(NAInterstitialAd *)ad {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)onInterstitialAdClosed:(NAInterstitialAd *)ad {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
