//
//  KsInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import "AdvKSInterstitialAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvKSInterstitialAdapter ()<KSInterstitialAdDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) KSInterstitialAd *ks_ad;

@end
 
@implementation AdvKSInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _ks_ad = [[KSInterstitialAd alloc] initWithPosId:placementId];
    _ks_ad.videoSoundEnabled = ![config[kAdvanceAdVideoMutedKey] boolValue];
    _ks_ad.delegate = self;
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _ks_ad.isValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_ks_ad setBidEcpm:result.winPrice highestLossEcpm:result.secondPrice];
    } else {
        KSAdExposureReportParam *param = [[KSAdExposureReportParam alloc] init];
        param.winEcpm = result.winPrice;
        [_ks_ad reportAdExposureFailed:KSAdExposureFailureBidFailed reportParam:param];
    }
}


#pragma mark: - KSSplashAdViewDelegate
/// 必须在此回调中处理 广告才有效
- (void)ksad_interstitialAdRenderSuccess:(KSInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didLoadAdWithAdapter:self price:interstitialAd.ecpm];
}

- (void)ksad_interstitialAdRenderFail:(KSInterstitialAd *)interstitialAd error:(NSError * _Nullable)error {
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)ksad_interstitialAdDidVisible:(KSInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)ksad_interstitialAdDidClick:(KSInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)ksad_interstitialAdDidClose:(KSInterstitialAd *)interstitialAd {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}


@end
