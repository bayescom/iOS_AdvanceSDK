//
//  AdvCSJFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJFullScreenVideoAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceFullScreenVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvCSJFullScreenVideoAdapter () <BUNativeExpressFullscreenVideoAdDelegate, AdvanceFullScreenVideoCommonAdapter>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvCSJFullScreenVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:placementId];
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_csj_ad loadAdData];
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
    [self.delegate fullscreenAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate fullscreenAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)fullscreenedVideoAd error:(NSError *_Nullable)error {
    [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate fullscreenAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

@end
