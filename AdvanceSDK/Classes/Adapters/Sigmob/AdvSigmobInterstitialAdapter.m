//
//  AdvSigmobInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "AdvSigmobInterstitialAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvSigmobInterstitialAdapter () <WindNewIntersititialAdDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) WindNewIntersititialAd *sigmob_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvSigmobInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindNewIntersititialAd alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_sigmob_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_sigmob_ad showAdFromRootViewController:rootViewController options:nil];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _sigmob_ad.ready;
    if (!valid) {
        [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark - WindNewIntersititialAdDelegate
- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd {
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:intersititialAd.getEcpm.integerValue];
}

- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd didFailWithError:(NSError *)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)intersititialAdDidVisible:(WindNewIntersititialAd *)intersititialAd {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)intersititialAdDidShowFailed:(WindNewIntersititialAd *)intersititialAd error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)intersititialAdDidClick:(WindNewIntersititialAd *)intersititialAd {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)intersititialAdDidClose:(WindNewIntersititialAd *)intersititialAd {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

@end
