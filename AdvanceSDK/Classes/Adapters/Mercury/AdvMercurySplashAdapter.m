#import "AdvMercurySplashAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvMercurySplashAdapter () <MercurySplashAdDelegate, AdvanceSplashCommonAdapter>
@property (nonatomic, strong) MercurySplashAd *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvMercurySplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:placementId delegate:self];
    _mercury_ad.controller = config[kAdvanceAdPresentControllerKey];
    _mercury_ad.bottomLogoView = config[kAdvanceSplashBottomViewKey];
}

- (void)adapter_loadAd {
    [_mercury_ad loadAd];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [self.mercury_ad showAdInWindow:window];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _mercury_ad.isAdValid;
    if (!valid) {
        [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - MercurySplashAdDelegate
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:splashAd.price];
}

- (void)mercury_splashAdFailToLoad:(MercurySplashAd * _Nullable)splashAd error:(NSError * _Nullable)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)mercury_splashAdRenderFail:(MercurySplashAd *)splashAd error:(NSError *)error {
    [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
