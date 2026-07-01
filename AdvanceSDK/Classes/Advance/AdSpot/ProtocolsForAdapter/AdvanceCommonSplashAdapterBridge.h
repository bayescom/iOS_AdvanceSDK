//
//  AdvanceCommonSplashAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/25.
//

@protocol AdvanceCommonSplashAdapter;

/// 开屏广告adapter的回调协议
@protocol AdvanceCommonSplashAdapterBridge <NSObject>

- (void)splash_didLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter price:(NSInteger)price;

- (void)splash_failedToLoadAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error;

- (void)splash_didAdExposuredWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter;

- (void)splash_failedToShowAdWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter error:(NSError *)error;

- (void)splash_didAdClickedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter;

- (void)splash_didAdClosedWithAdapter:(id<AdvanceCommonSplashAdapter>)adapter;

@end
