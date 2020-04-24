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

@interface CsjSplashAdapter ()  <BUNativeExpressSplashViewDelegate>
@property (nonatomic, strong) BUNativeExpressSplashView *csj_ad;
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
    _csj_ad = [[BUNativeExpressSplashView alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid adSize:[UIScreen mainScreen].bounds.size rootViewController:_adspot.viewController];
    _csj_ad.delegate = self;

    if (self.adspot.currentSdkSupplier.timeout &&
        self.adspot.currentSdkSupplier.timeout > 0) {
        _csj_ad.tolerateTimeout = _adspot.currentSdkSupplier.timeout / 1000;
    } else {
        _csj_ad.tolerateTimeout = 5.0;
    }
    [_csj_ad loadAdData];
    UIWindow *window = [UIApplication sharedApplication].by_getCurrentWindow;
    [window addSubview:_csj_ad];
}

// MARK: ======================= BUNativeExpressSplashViewDelegate =======================
- (void)nativeExpressSplashViewDidLoad:(BUNativeExpressSplashView *)splashAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
        [self.delegate advanceSplashOnAdReceived];
    }
}

- (void)nativeExpressSplashView:(BUNativeExpressSplashView *)splashAdView didFailWithError:(NSError * _Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
    [self.adspot selectSdkSupplierWithError:error];
}

- (void)nativeExpressSplashViewWillVisible:(BUNativeExpressSplashView *)splashAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdShow)]) {
        [self.delegate advanceSplashOnAdShow];
    }
}

- (void)nativeExpressSplashViewDidClick:(BUNativeExpressSplashView *)splashAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdClicked)]) {
        [self.delegate advanceSplashOnAdClicked];
    }
}

- (void)nativeExpressSplashViewDidClose:(nonnull UIView *)splashAdView {
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
}

- (void)nativeExpressSplashViewCountdownToZero:(nonnull BUNativeExpressSplashView *)splashAdView {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}


- (void)nativeExpressSplashViewDidClickSkip:(nonnull BUNativeExpressSplashView *)splashAdView {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}


- (void)nativeExpressSplashViewFinishPlayDidPlayFinish:(nonnull BUNativeExpressSplashView *)splashView didFailWithError:(nonnull NSError *)error {
    
}


- (void)nativeExpressSplashViewRenderFail:(nonnull BUNativeExpressSplashView *)splashAdView error:(NSError * _Nullable)error {
    [self.adspot selectSdkSupplierWithError:error];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
}


- (void)nativeExpressSplashViewRenderSuccess:(nonnull BUNativeExpressSplashView *)splashAdView {
    
}


@end
