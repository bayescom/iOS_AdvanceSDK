//
//  AdvGDTFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTFullScreenVideoAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceFullScreenVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTFullScreenVideoAdapter () <GDTUnifiedInterstitialAdDelegate, AdvanceFullScreenVideoCommonAdapter>
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvGDTFullScreenVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:placementId];
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_gdt_ad loadFullScreenAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_gdt_ad presentFullScreenAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _gdt_ad.isAdValid;
    if (!valid) {
        [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - GDTUnifiedInterstitialAdDelegate
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:unifiedInterstitial.eCPM];
    [self.delegate fullscreenAdapter_didLoadAdWithAdapterId:self.adapterId price:unifiedInterstitial.eCPM];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate fullscreenAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

/// 渲染失败
- (void)unifiedInterstitialRenderFail:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

/// 展示失败
- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate fullscreenAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate fullscreenAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    [self.delegate fullscreenAdapter_didAdClosedWithAdapterId:self.adapterId];
}

/// 视频播放状态发生改变
- (void)unifiedInterstitialAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status {
    if (status == GDTMediaPlayerStatusStoped) {
        [self.delegate fullscreenAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
    }
}

@end
