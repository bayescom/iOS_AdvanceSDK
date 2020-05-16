//
//  CsjInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjInterstitialAdapter.h"

#if __has_include(<BUAdSDK/BUNativeExpressInterstitialAd.h>)
#import <BUAdSDK/BUNativeExpressInterstitialAd.h>
#else
#import "BUNativeExpressInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"

@interface CsjInterstitialAdapter () <BUNativeExpresInterstitialAdDelegate>
@property (nonatomic, strong) BUNativeExpressInterstitialAd *csj_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceInterstitial *adspot;

@end

@implementation CsjInterstitialAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _csj_ad = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid adSize:CGSizeMake(300, 450)];
    _csj_ad.delegate = self;
    [_csj_ad loadAdData];
}

- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= BUNativeExpresInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdReceived)]) {
        [self.delegate advanceInterstitialOnAdReceived];
    }
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceInterstitialOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 插屏广告渲染失败
- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdRenderFailed)]) {
        [self.delegate advanceInterstitialOnAdRenderFailed];
    }
    [self.adspot selectSdkSupplierWithError:error];
}


/// 插屏广告曝光回调
- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdShow)]) {
        [self.delegate advanceInterstitialOnAdShow];
    }
}

/// 插屏广告点击回调
- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClicked)]) {
        [self.delegate advanceInterstitialOnAdClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdClosed)]) {
        [self.delegate advanceInterstitialOnAdClosed];
    }
}

/// 广告可以调用Show
- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnReadyToShow)]) {
        [self.delegate advanceInterstitialOnReadyToShow];
    }
}

@end
