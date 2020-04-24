//
//  CsjSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by 程立卿 on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "CsjSplashAdapter.h"

#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK/BUAdSDK.h"
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Advance.h"

@interface CsjSplashAdapter ()  <BUSplashAdDelegate>

@property (nonatomic, strong) BUSplashAdView *csj_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) NSDictionary *params;

@end

@implementation CsjSplashAdapter
- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    
    _csj_ad = [[BUSplashAdView alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid frame:[UIScreen mainScreen].bounds];
    if (self.adspot.currentSdkSupplier.timeout &&
        self.adspot.currentSdkSupplier.timeout > 0) {
        _csj_ad.tolerateTimeout = _adspot.currentSdkSupplier.timeout / 1000;
    } else {
        _csj_ad.tolerateTimeout = 5.0;
    }
    _csj_ad.delegate = self;
    
    [_csj_ad loadAdData];
    [[UIApplication sharedApplication].by_getCurrentWindow.rootViewController.view addSubview:_csj_ad];
    _csj_ad.rootViewController = [UIApplication sharedApplication].by_getCurrentWindow.rootViewController;
}

// MARK: ======================= BUSplashAdDelegate =======================
/**
 This method is called when splash ad material loaded successfully.
 */
- (void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
        [self.delegate advanceSplashOnAdReceived];
    }
}

/**
 This method is called when splash ad material failed to load.
 @param error : the reason of error
 */
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithAdapterId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithAdapterId:_adspot.currentSdkSupplier.adspotid error:error];
    }
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
    [self.adspot selectSdkSupplierWithError:error];
}

/**
 This method is called when splash ad slot will be showing.
 */
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdShow)]) {
        [self.delegate advanceSplashOnAdShow];
    }
}

/**
 This method is called when splash ad is clicked.
 */
- (void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdClicked)]) {
        [self.delegate advanceSplashOnAdClicked];
    }
}

/**
 This method is called when splash ad is closed.
 */
- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
}

/**
 This method is called when spalashAd skip button  is clicked.
 */
- (void)splashAdDidClickSkip:(BUSplashAdView *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

/**
 This method is called when spalashAd countdown equals to zero
 */
- (void)splashAdCountdownToZero:(BUSplashAdView *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

@end
