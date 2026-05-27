//
//  AdvSigmobSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvSigmobSplashAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvSigmobSplashAdapter () <WindSplashAdViewDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) WindSplashAdView *sigmob_ad;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvSigmobSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindSplashAdView alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
    _sigmob_ad.rootViewController = config[kAdvanceAdPresentControllerKey];
    [_sigmob_ad loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    CGRect adFrame = [UIScreen mainScreen].bounds;
    // 设置logo
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [window addSubview:_bottomLogoView];
    }
    _sigmob_ad.frame = adFrame;
    [window addSubview:_sigmob_ad];
}

- (BOOL)adapter_isAdValid {
    return _sigmob_ad.adValid;
}

//- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
//    
//}

#pragma mark - WindMillSplashAdDelegate
- (void)onSplashAdDidLoad:(WindSplashAdView *)splashAdView {
    [self.bridge splash_didLoadAdWithAdapter:self price:splashAdView.getEcpm.integerValue];
}

- (void)onSplashAdLoadFail:(WindSplashAdView *)splashAdView error:(NSError *)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)onSplashAdSuccessPresentScreen:(WindSplashAdView *)splashAdView {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)onSplashAdFailToPresent:(WindSplashAdView *)splashAdView withError:(NSError *)error {
    [self.bridge splash_failedToShowAdWithAdapter:self error:error];
}

- (void)onSplashAdClicked:(WindSplashAdView *)splashAdView {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)onSplashAdClosed:(WindSplashAdView *)splashAdView {
    [self sigmobAdDidClose];
}

- (void)sigmobAdDidClose {
    [_sigmob_ad removeFromSuperview];
    [_bottomLogoView removeFromSuperview];
    _sigmob_ad = nil;
    [self.bridge splash_didAdClosedWithAdapter:self];
}

@end
