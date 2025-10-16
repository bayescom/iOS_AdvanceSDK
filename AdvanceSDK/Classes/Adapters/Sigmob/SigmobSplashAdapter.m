//
//  SigmobSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "SigmobSplashAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface SigmobSplashAdapter () <WindSplashAdViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) WindSplashAdView *sigmob_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation SigmobSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        WindAdRequest *request = [WindAdRequest request];
        request.placementId = supplier.adspotid;
        _sigmob_ad = [[WindSplashAdView alloc] initWithRequest:request];
        _sigmob_ad.delegate = self;
        _sigmob_ad.rootViewController = _adspot.viewController;
    }
    return self;
}

- (void)loadAd {
    [_sigmob_ad loadAdData];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (BOOL)isAdValid {
    return _sigmob_ad.adValid;
}

- (void)showInWindow:(UIWindow *)window {
    CGRect adFrame = [UIApplication sharedApplication].keyWindow.bounds;
    // 设置logo
    if (_adspot.bottomLogoView) {
        adFrame.size.height -= _adspot.bottomLogoView.bounds.size.height;
        _adspot.bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _adspot.bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _adspot.bottomLogoView.bounds.size.height);
        [window addSubview:_adspot.bottomLogoView];
    }
    self.sigmob_ad.frame = adFrame;
    [window addSubview:self.sigmob_ad];
}


#pragma mark - WindMillSplashAdDelegate
- (void)onSplashAdDidLoad:(WindSplashAdView *)splashAdView {
    [self.adspot.manager setECPMIfNeeded:splashAdView.getEcpm.integerValue supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)onSplashAdLoadFail:(WindSplashAdView *)splashAdView error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)onSplashAdSuccessPresentScreen:(WindSplashAdView *)splashAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.sigmob_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onSplashAdClicked:(WindSplashAdView *)splashAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onSplashAdClosed:(WindSplashAdView *)splashAdView {
    [_adspot.bottomLogoView removeFromSuperview];
    [_sigmob_ad removeFromSuperview];
    _sigmob_ad = nil;
    
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
