//
//  AdvanceCommonInterstitialAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/26.
//

@protocol AdvanceCommonInterstitialAdapter;

/// 插屏广告adapter的回调协议
@protocol AdvanceCommonInterstitialAdapterBridge <NSObject>

- (void)interstitial_didLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter price:(NSInteger)price;

- (void)interstitial_failedToLoadAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error;

- (void)interstitial_didAdExposuredWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter;

- (void)interstitial_failedToShowAdWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter error:(NSError *)error;

- (void)interstitial_didAdClickedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter;

- (void)interstitial_didAdClosedWithAdapter:(id<AdvanceCommonInterstitialAdapter>)adapter;

@end
