//
//  MercuryInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryInterstitialAdapter.h"
#if __has_include(<MercurySDK/MercuryInterstitialAd.h>)
#import <MercurySDK/MercuryInterstitialAd.h>
#else
#import "MercuryInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"

@interface MercuryInterstitialAdapter () <MercuryInterstitialAdDelegate>
@property (nonatomic, strong) MercuryInterstitialAd *mercury_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceInterstitial *adspot;

@end

@implementation MercuryInterstitialAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _mercury_ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:_adspot.currentSdkSupplier.adspotid delegate:self];
    [_mercury_ad loadAd];
}

- (void)showAd {
    [_mercury_ad presentAdFromViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}


// MARK: ======================= MercuryInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)mercury_interstitialSuccess  {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdReceived)]) {
        [self.delegate advanceInterstitialOnAdReceived];
    }
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnReadyToShow)]) {
        [self.delegate advanceInterstitialOnReadyToShow];
    }
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)mercury_interstitialFailError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceInterstitialOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 插屏广告视图曝光失败回调，插屏广告曝光失败回调该函数
- (void)mercury_interstitialFailToPresent {
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdRenderFailed)]) {
        [self.delegate advanceInterstitialOnAdRenderFailed];
    }
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    [self.adspot selectSdkSupplierWithError:nil];
}

/// 插屏广告曝光回调
- (void)mercury_interstitialWillExposure {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdShow)]) {
        [self.delegate advanceInterstitialOnAdShow];
    }
}

/// 插屏广告点击回调
- (void)mercury_interstitialClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClicked)]) {
        [self.delegate advanceInterstitialOnAdClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)mercury_interstitialDidDismissScreen {
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClosed)]) {
        [self.delegate advanceInterstitialOnAdClosed];
    }
}

@end
