//
//  CsjInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJInterstitialAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvCSJInterstitialAdapter () <BUNativeExpressFullscreenVideoAdDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvCSJInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:placementId];
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [self.csj_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_csj_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

#pragma mark: - BUNativeExpressFullscreenVideoAdDelegate
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
