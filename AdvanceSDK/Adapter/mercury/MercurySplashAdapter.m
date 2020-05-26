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

@interface MercurySplashAdapter () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *mercury_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceSplash *adspot;

@end

@implementation MercurySplashAdapter
- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:_adspot.currentSdkSupplier.adspotid delegate:self];
    _mercury_ad.placeholderImage = _adspot.backgroundImage;
    _mercury_ad.logoImage = _adspot.logoImage;
    if (_adspot.showLogoRequire) {
        _mercury_ad.showType = MercurySplashAdShowCutBottom;
    }
    _mercury_ad.delegate = self;
//    _mercury_ad.showType = MercurySplashAdShowCutBottom;
    _mercury_ad.controller = _adspot.viewController;
    [_mercury_ad loadAdAndShow];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
        [self.delegate advanceSplashOnAdReceived];
    }
}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdShow)]) {
        [self.delegate advanceSplashOnAdShow];
    }
}

- (void)mercury_splashAdFailError:(nullable NSError *)error {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdClicked)]) {
        [self.delegate advanceSplashOnAdClicked];
    }
}

- (void)mercury_splashAdLifeTime:(NSUInteger)time {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

- (void)mercury_splashAdSkipClicked:(MercurySplashAd *)splashAd {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

@end
