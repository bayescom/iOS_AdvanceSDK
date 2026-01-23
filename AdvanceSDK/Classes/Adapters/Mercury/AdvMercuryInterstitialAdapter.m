//
//  AdvMercuryInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryInterstitialAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvMercuryInterstitialAdapter () <MercuryInterstitialAdDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) MercuryInterstitialAd *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvMercuryInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _mercury_ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:placementId delegate:self];
}

- (void)adapter_loadAd {
    [_mercury_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_mercury_ad presentAdFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _mercury_ad.isAdValid;
    if (!valid) {
        [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - MercuryInterstitialAdDelegate
- (void)mercury_interstitialSuccessToLoadAd:(MercuryInterstitialAd *)interstitialAd  {
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:interstitialAd.price];
}

- (void)mercury_interstitialFailToLoadAd:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)mercury_interstitialRenderFail:(MercuryInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)mercury_interstitialDidPresentScreen:(MercuryInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)mercury_interstitialClicked:(MercuryInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)mercury_interstitialDidDismissScreen:(MercuryInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
