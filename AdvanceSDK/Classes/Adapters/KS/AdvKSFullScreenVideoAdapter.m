//
//  AdvKSFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSFullScreenVideoAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvKSFullScreenVideoAdapter ()<KSFullscreenVideoAdDelegate, AdvanceCommonFullscreenVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonFullscreenVideoAdapterBridge> bridge;
@property (nonatomic, strong) KSFullscreenVideoAd *ks_ad;

@end

@implementation AdvKSFullScreenVideoAdapter

- (void)adapter_setFullscreenBridge:(id<AdvanceCommonFullscreenVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _ks_ad = [[KSFullscreenVideoAd alloc] initWithPosId:placementId];
    _ks_ad.showDirection = KSAdShowDirection_Vertical;
    _ks_ad.shouldMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _ks_ad.delegate = self;
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showAdFromRootViewController:rootViewController];
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

#pragma mark: - KSFullscreenVideoAdDelegate
- (void)fullscreenVideoAdDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didLoadAdWithAdapter:self price:fullscreenVideoAd.ecpm];
}

- (void)fullscreenVideoAd:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge fullscreen_failedToLoadAdWithAdapter:self error:error];
}

- (void)fullscreenVideoAdDidVisible:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdExposuredWithAdapter:self];
}

- (void)fullscreenVideoAdDidClick:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdClickedWithAdapter:self];
}

- (void)fullscreenVideoAdDidClose:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdClosedWithAdapter:self];
}

- (void)fullscreenVideoAdDidPlayFinish:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        [self.bridge fullscreen_didAdPlayFinishWithAdapter:self];
    }
}

@end
