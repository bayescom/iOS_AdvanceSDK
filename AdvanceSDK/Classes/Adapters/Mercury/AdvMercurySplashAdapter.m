#import "AdvMercurySplashAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvMercurySplashAdapter () <MercurySplashAdDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) MercurySplashAd *mercury_ad;

@end

@implementation AdvMercurySplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:placementId delegate:self];
    _mercury_ad.controller = config[kAdvanceAdPresentControllerKey];
    _mercury_ad.bottomLogoView = config[kAdvanceSplashBottomViewKey];
    [_mercury_ad loadAd];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [_mercury_ad showAdInWindow:window];
}

- (BOOL)adapter_isAdValid {
    return _mercury_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [_mercury_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - MercurySplashAdDelegate
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    [self.bridge splash_didLoadAdWithAdapter:self price:splashAd.price];
}

- (void)mercury_splashAdFailToLoad:(MercurySplashAd * _Nullable)splashAd error:(NSError * _Nullable)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)mercury_splashAdRenderFail:(MercurySplashAd *)splashAd error:(NSError *)error {
    [self.bridge splash_failedToShowAdWithAdapter:self error:error];
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
