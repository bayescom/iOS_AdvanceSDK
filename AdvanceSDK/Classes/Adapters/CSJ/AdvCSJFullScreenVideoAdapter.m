//
//  AdvCSJFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJFullScreenVideoAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvCSJFullScreenVideoAdapter () <BUNativeExpressFullscreenVideoAdDelegate, AdvanceCommonFullscreenVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonFullscreenVideoAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;

@end

@implementation AdvCSJFullScreenVideoAdapter

- (void)adapter_setFullscreenBridge:(id<AdvanceCommonFullscreenVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:placementId];
    _csj_ad.delegate = self;
    [_csj_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_csj_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_csj_ad win:@(result.secondPrice)];
    } else {
        [_csj_ad loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark: - BUNativeExpressFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    [self.bridge fullscreen_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge fullscreen_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)fullscreenedVideoAd error:(NSError *_Nullable)error {
    [self.bridge fullscreen_failedToShowAdWithAdapter:self error:error];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdExposuredWithAdapter:self];
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdClickedWithAdapter:self];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.bridge fullscreen_didAdClosedWithAdapter:self];
}

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge fullscreen_didAdPlayFinishWithAdapter:self];
}

@end
