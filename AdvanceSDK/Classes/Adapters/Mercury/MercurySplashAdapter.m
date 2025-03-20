//
//  MercurySplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercurySplashAdapter.h"

#if __has_include(<MercurySDK/MercurySplashAd.h>)
#import <MercurySDK/MercurySplashAd.h>
#else
#import "MercurySplashAd.h"
#endif

#import "AdvanceSplash.h"
#import "AdvLog.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceAdapter.h"

@interface MercurySplashAdapter () <MercurySplashAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) MercurySplashAd *mercury_ad;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, weak) AdvanceSplash *adspot;

@end

@implementation MercurySplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
        _mercury_ad.logoImage = _adspot.logoImage;
        _mercury_ad.fetchDelay = _supplier.timeout * 1.0 / 1000.0;
    }
    return self;
}

- (void)loadAd {
    [_mercury_ad loadAd];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (void)showInWindow:(UIWindow *)window {
    _mercury_ad.controller = _adspot.viewController;
    [self.mercury_ad showAdInWindow:window];

}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    [self.adspot.manager setECPMIfNeeded:splashAd.price supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)mercury_splashAdFailToLoad:(MercurySplashAd * _Nullable)splashAd error:(NSError * _Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {

    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.mercury_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


@end
