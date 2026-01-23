//
//  AdvSigmobSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvSigmobSplashAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvSigmobSplashAdapter () <WindSplashAdViewDelegate, AdvanceSplashCommonAdapter>
@property (nonatomic, strong) WindSplashAdView *sigmob_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvSigmobSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindSplashAdView alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
    _sigmob_ad.rootViewController = config[kAdvanceAdPresentControllerKey];
}

- (void)adapter_loadAd {
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
    [window addSubview:self.sigmob_ad];
}

- (BOOL)adapter_isAdValid {
    BOOL valid =  _sigmob_ad.adValid;
    if (!valid) {
        [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark - WindMillSplashAdDelegate
- (void)onSplashAdDidLoad:(WindSplashAdView *)splashAdView {
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:splashAdView.getEcpm.integerValue];
}

- (void)onSplashAdLoadFail:(WindSplashAdView *)splashAdView error:(NSError *)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)onSplashAdSuccessPresentScreen:(WindSplashAdView *)splashAdView {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)onSplashAdFailToPresent:(WindSplashAdView *)splashAdView withError:(NSError *)error {
    [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)onSplashAdClicked:(WindSplashAdView *)splashAdView {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)onSplashAdClosed:(WindSplashAdView *)splashAdView {
    [self sigmobAdDidClose];
}

- (void)sigmobAdDidClose {
    [_sigmob_ad removeFromSuperview];
    [_bottomLogoView removeFromSuperview];
    _sigmob_ad = nil;
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

@end
