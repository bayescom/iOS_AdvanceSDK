//
//  AdvCSJSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvCSJSplashAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvCSJSplashAdapter () <BUSplashAdDelegate, AdvanceSplashCommonAdapter>

@property (nonatomic, strong) BUSplashAd *csj_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvCSJSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    CGRect adFrame = [UIScreen mainScreen].bounds;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
    }
    _csj_ad = [[BUSplashAd alloc] initWithSlotID:placementId adSize:adFrame.size];
    _csj_ad.delegate = self;
    _csj_ad.tolerateTimeout = timeout * 1.0 / 1000.0;
}

- (void)adapter_loadAd {
    [self.csj_ad loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    if (window.rootViewController) {
        [self.csj_ad showSplashViewInRootViewController:window.rootViewController];
    }
}

- (BOOL)adapter_isAdValid {
    return YES;
}

#pragma mark: - BUSplashAdDelegate
- (void)splashAdLoadSuccess:(nonnull BUSplashAd *)splashAd {
    NSDictionary *ext = splashAd.mediaExt;
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)splashAdLoadFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)splashAdRenderSuccess:(BUSplashAd *)splashAd {
    // 设置logo
    if (_bottomLogoView) {
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [_csj_ad.splashRootViewController.view addSubview:_bottomLogoView];
    }
}

- (void)splashAdRenderFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)splashAdDidShow:(nonnull BUSplashAd *)splashAd {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)splashAdDidClick:(nonnull BUSplashAd *)splashAd {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)splashAdDidClose:(nonnull BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    [self csjAdDidClose];
}

- (void)csjAdDidClose {
    [_bottomLogoView removeFromSuperview];
    [self.csj_ad removeSplashView];
    self.csj_ad = nil;
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)splashAdViewControllerDidClose:(nonnull BUSplashAd *)splashAd {}
- (void)splashAdWillShow:(nonnull BUSplashAd *)splashAd {}
- (void)splashDidCloseOtherController:(nonnull BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {}
- (void)splashVideoAdDidPlayFinish:(nonnull BUSplashAd *)splashAd didFailWithError:(NSError * _Nullable)error {}

- (void)dealloc {
    
}

@end
