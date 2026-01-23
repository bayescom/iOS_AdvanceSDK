//
//  AdvGDTSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Gdt. All rights reserved.
//

#import "AdvGDTSplashAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTSplashAdapter () <GDTSplashAdDelegate, AdvanceSplashCommonAdapter>
@property (nonatomic, strong) GDTSplashAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvGDTSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    _gdt_ad = [[GDTSplashAd alloc] initWithPlacementId:placementId];
    _gdt_ad.delegate = self;
    _gdt_ad.fetchDelay = timeout * 1.0 / 1000.0;
}

- (void)adapter_loadAd {
    [_gdt_ad loadAd];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [_gdt_ad showAdInWindow:window withBottomView:_bottomLogoView skipView:nil];
}

- (BOOL)adapter_isAdValid {
    BOOL valid =  _gdt_ad.isAdValid;
    if (!valid) {
        [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - GDTSplashAdDelegate
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:splashAd.eCPM];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {

}

@end
