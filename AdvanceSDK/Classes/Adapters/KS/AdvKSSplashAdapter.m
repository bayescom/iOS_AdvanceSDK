//
//  AdvKSSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//

#import "AdvKSSplashAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvKSSplashAdapter ()<KSSplashAdViewDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) KSSplashAdView *ks_ad;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvKSSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    _ks_ad = [[KSSplashAdView alloc] initWithPosId:placementId];
    _ks_ad.delegate = self;
    _ks_ad.rootViewController = config[kAdvanceAdPresentControllerKey];
    _ks_ad.timeoutInterval = timeout * 1.0 / 1000.0;
    [_ks_ad loadAdData];
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

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_ks_ad setBidEcpm:result.winPrice highestLossEcpm:result.secondPrice];
    } else {
        KSAdExposureReportParam *param = [[KSAdExposureReportParam alloc] init];
        param.winEcpm = result.winPrice;
        [_ks_ad reportAdExposureFailed:KSAdExposureFailureBidFailed reportParam:param];
    }
}

#pragma mark: - KSSplashAdViewDelegate
- (void)ksad_splashAdContentDidLoad:(KSSplashAdView *)splashAdView {
    [self.bridge splash_didLoadAdWithAdapter:self price:splashAdView.ecpm];
}

- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didFailWithError:(NSError *)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)ksad_splashAdDidVisible:(KSSplashAdView *)splashAdView {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)ksad_splashAdDidClick:(KSSplashAdView *)splashAdView {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)ksad_splashAdDidClose:(KSSplashAdView *)splashAdView {
    [self ksAdDidClose];
}

- (void)ksAdDidClose {
    [_ks_ad removeFromSuperview];
    [_bottomLogoView removeFromSuperview];
    _ks_ad = nil;
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)dealloc {
   
}

@end
