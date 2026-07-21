//
//  AdvNoahSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahSplashAdapter.h"
#import <NoahSDK/NoahSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvNoahSplashAdapter () <NoahSplashAdListener, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) SplashAd *noah_ad;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvNoahSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    RequestInfo *req = [RequestInfo new];
    req.slotKey = placementId;
    req.timeoutInterval = timeout;
    req.splashBottomView = _bottomLogoView;
    [SplashAd loadAdWithReqInfo:req adDelegate:self];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    if (window.rootViewController) {
        [_noah_ad showAdInViewController:window.rootViewController];
    }
}

- (BOOL)adapter_isAdValid {
    return _noah_ad.isValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_noah_ad sendWinNotification:result.secondPrice];
    } else {
        [_noah_ad sendLossNotification:result.winPrice reason:0];
    }
}


#pragma mark: - NoahSplashAdListener
- (void)onSplashAdLoaded:(SplashAd *)ad {
    self.noah_ad = ad;
    [self.bridge splash_didLoadAdWithAdapter:self price:ad.price];
}

- (void)onSplashAdLoadFail:(RequestInfo *)reqInfo error:(AdError *)error {
    NSError *err = [NSError errorWithDomain:@"NoahAdErrorDomain" code:[error getErrorCode] userInfo:@{NSLocalizedDescriptionKey: [error getErrorMessage] ?: @""}];
    [self.bridge splash_failedToLoadAdWithAdapter:self error:err];
}

- (void)onSplashAdShown:(SplashAd *)ad {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)onSplashAdClicked:(SplashAd *)ad {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)onSplashAdClosed:(SplashAd *)ad {
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
