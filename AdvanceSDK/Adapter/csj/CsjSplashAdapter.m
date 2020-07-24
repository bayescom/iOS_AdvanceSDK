//
//  CsjSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "CsjSplashAdapter.h"

#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Advance.h"

@interface CsjSplashAdapter ()  <BUSplashAdDelegate>

@property (nonatomic, strong) BUSplashAdView *csj_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) NSDictionary *params;

@property (nonatomic, strong) UIImageView *backgroundImageV;

@end

@implementation CsjSplashAdapter
- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
        // 占位背景
        if (_adspot.backgroundImage) {
            _backgroundImageV = [[UIImageView alloc] initWithImage:_adspot.backgroundImage];
            _backgroundImageV.frame = [UIScreen mainScreen].bounds;
            [_adspot.viewController.view addSubview:_backgroundImageV];
        }
    }
    return self;
}

- (void)loadAd {
    CGRect adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    // 设置logo
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
    }
    _csj_ad = [[BUSplashAdView alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid frame:adFrame];
    if (self.adspot.currentSdkSupplier.timeout &&
        self.adspot.currentSdkSupplier.timeout > 0) {
        _csj_ad.tolerateTimeout = _adspot.currentSdkSupplier.timeout / 1000;
    } else {
        _csj_ad.tolerateTimeout = 5.0;
    }
    _csj_ad.delegate = self;
    
    [_csj_ad loadAdData];
    _backgroundImageV.userInteractionEnabled = YES;
    [_backgroundImageV addSubview:_csj_ad];
    _csj_ad.backgroundColor = [UIColor clearColor];
    _csj_ad.rootViewController = _adspot.viewController;
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
    if (_adspot.showLogoRequire) {
        // 添加Logo
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
        imgV.image = _adspot.logoImage;
        if (imgV) {
            [_csj_ad addSubview:imgV];
        }
    }
}

/**
 This method is called when splash ad material failed to load.
 @param error : the reason of error
 */
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.currentSdkSupplier.adspotid error:error];
    }
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    [_backgroundImageV removeFromSuperview];
    _backgroundImageV = nil;
    [self.adspot selectSdkSupplierWithError:error];
}

/**
 This method is called when splash ad slot will be showing.
 */
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
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
    [_backgroundImageV removeFromSuperview];
    [_csj_ad removeFromSuperview];
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    _csj_ad = nil;
}

/**
 This method is called when spalashAd skip button  is clicked.
 */
- (void)splashAdDidClickSkip:(BUSplashAdView *)splashAd {
    [_backgroundImageV removeFromSuperview];
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

/**
 This method is called when spalashAd countdown equals to zero
 */
- (void)splashAdCountdownToZero:(BUSplashAdView *)splashAd {
    [_backgroundImageV removeFromSuperview];
    [[_adspot performSelector:@selector(bgImgV)] removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

@end
