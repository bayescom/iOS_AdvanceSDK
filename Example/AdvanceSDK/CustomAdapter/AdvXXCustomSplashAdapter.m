//
//  AdvXXCustomSplashAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/3.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomSplashAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvanceCommonAdapter.h>
#import <AdvanceSDK/AdvAdConfigHeader.h>

@interface AdvXXCustomSplashAdapter () <BUSplashAdDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) BUSplashAd *splashAd;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvXXCustomSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    CGRect adFrame = [UIScreen mainScreen].bounds;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
    }
    _splashAd = [[BUSplashAd alloc] initWithSlotID:placementId adSize:adFrame.size];
    _splashAd.delegate = self;
    _splashAd.tolerateTimeout = timeout * 1.0 / 1000.0;
    [_splashAd loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    if (window.rootViewController) {
        [_splashAd showSplashViewInRootViewController:window.rootViewController];
    }
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_splashAd win:@(result.secondPrice)];
    } else {
        [_splashAd loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}

#pragma mark: - BUSplashAdDelegate
- (void)splashAdLoadSuccess:(nonnull BUSplashAd *)splashAd {
    NSDictionary *ext = splashAd.mediaExt;
    [self.bridge splash_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)splashAdLoadFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)splashAdRenderFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.bridge splash_failedToShowAdWithAdapter:self error:error];
}

- (void)splashAdWillShow:(nonnull BUSplashAd *)splashAd {
    // 设置logoView
    if (_bottomLogoView) {
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [_splashAd.splashRootViewController.view addSubview:_bottomLogoView];
    }
}

- (void)splashAdDidShow:(nonnull BUSplashAd *)splashAd {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)splashAdDidClick:(nonnull BUSplashAd *)splashAd {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)splashAdDidClose:(nonnull BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    [self csjAdDidClose];
}

- (void)csjAdDidClose {
    [_bottomLogoView removeFromSuperview];
    [self.splashAd removeSplashView];
    self.splashAd = nil;
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)splashAdRenderSuccess:(BUSplashAd *)splashAd {}
- (void)splashAdViewControllerDidClose:(nonnull BUSplashAd *)splashAd {}
- (void)splashDidCloseOtherController:(nonnull BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {}
- (void)splashVideoAdDidPlayFinish:(nonnull BUSplashAd *)splashAd didFailWithError:(NSError * _Nullable)error {}

- (void)dealloc {
    
}

@end
