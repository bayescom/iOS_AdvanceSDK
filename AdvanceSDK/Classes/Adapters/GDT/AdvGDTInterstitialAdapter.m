//
//  AdvGDTInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTInterstitialAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTInterstitialAdapter () <GDTUnifiedInterstitialAdDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) GDTUnifiedInterstitialAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvGDTInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _gdt_ad = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:placementId];
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_gdt_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_gdt_ad presentAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _gdt_ad.isAdValid;
    if (!valid) {
        [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - GDTUnifiedInterstitialAdDelegate
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:unifiedInterstitial.eCPM];
}

- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

/// 渲染失败
- (void)unifiedInterstitialRenderFail:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

/// 展示失败
- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)unifiedInterstitialWillExposure:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)unifiedInterstitialDidDismissScreen:(id)unifiedInterstitial {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
