//
//  AdvKSSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//

#import "AdvKSSplashAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvKSSplashAdapter ()<KSSplashAdViewDelegate, AdvanceSplashCommonAdapter>

@property (nonatomic, strong) KSSplashAdView *ks_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvKSSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    _ks_ad = [[KSSplashAdView alloc] initWithPosId:placementId];
    _ks_ad.delegate = self;
    _ks_ad.rootViewController = config[kAdvanceAdPresentControllerKey];
        _ks_ad.timeoutInterval = timeout * 1.0 / 1000.0;
}

- (void)adapter_loadAd {
    [self.ks_ad loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    CGRect adFrame = [UIScreen mainScreen].bounds;
    // 设置logo
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [window addSubview:_bottomLogoView];
    }
    _ks_ad.frame = adFrame;
    [_ks_ad showInView:window];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

#pragma mark: - KSSplashAdViewDelegate
- (void)ksad_splashAdContentDidLoad:(KSSplashAdView *)splashAdView {
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:splashAdView.ecpm];
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:splashAdView.ecpm];
}

- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didFailWithError:(NSError *)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)ksad_splashAdDidVisible:(KSSplashAdView *)splashAdView {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)ksad_splashAdDidClick:(KSSplashAdView *)splashAdView {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)ksad_splashAdDidClose:(KSSplashAdView *)splashAdView {
    [self ksAdDidClose];
}

- (void)ksAdDidClose {
    [_ks_ad removeFromSuperview];
    [_bottomLogoView removeFromSuperview];
    _ks_ad = nil;
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
   
}

@end
