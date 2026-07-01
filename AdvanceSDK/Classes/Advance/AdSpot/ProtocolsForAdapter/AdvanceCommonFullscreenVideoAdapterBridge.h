//
//  AdvanceCommonFullscreenVideoAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/26.
//

@protocol AdvanceCommonFullscreenVideoAdapter;

/// 全屏视频广告adapter的回调协议
@protocol AdvanceCommonFullscreenVideoAdapterBridge <NSObject>

- (void)fullscreen_didLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter price:(NSInteger)price;

- (void)fullscreen_failedToLoadAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error;

- (void)fullscreen_didAdExposuredWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter;

- (void)fullscreen_failedToShowAdWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter error:(NSError *)error;

- (void)fullscreen_didAdClickedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter;

- (void)fullscreen_didAdClosedWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter;

- (void)fullscreen_didAdPlayFinishWithAdapter:(id<AdvanceCommonFullscreenVideoAdapter>)adapter;

@end

