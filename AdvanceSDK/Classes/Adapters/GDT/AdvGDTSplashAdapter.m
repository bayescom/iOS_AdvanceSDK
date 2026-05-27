//
//  AdvGDTSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Gdt. All rights reserved.
//

#import "AdvGDTSplashAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvGDTSplashAdapter () <GDTSplashAdDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) GDTSplashAd *gdt_ad;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvGDTSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    _gdt_ad = [[GDTSplashAd alloc] initWithPlacementId:placementId];
    _gdt_ad.delegate = self;
    _gdt_ad.fetchDelay = timeout * 1.0 / 1000.0;
    [_gdt_ad loadAd];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [_gdt_ad showAdInWindow:window withBottomView:_bottomLogoView skipView:nil];
}

- (BOOL)adapter_isAdValid {
    return _gdt_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_gdt_ad sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [_gdt_ad sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}


#pragma mark: - GDTSplashAdDelegate
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    [self.bridge splash_didLoadAdWithAdapter:self price:splashAd.eCPM];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)dealloc {

}

@end
