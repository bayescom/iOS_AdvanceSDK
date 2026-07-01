//
//  AdvanceCommonBannerAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/26.
//

@protocol AdvanceCommonBannerAdapter;

/// banner广告adapter的回调协议
@protocol AdvanceCommonBannerAdapterBridge <NSObject>

- (void)banner_didLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter price:(NSInteger)price;

- (void)banner_failedToLoadAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error;

- (void)banner_didAdExposuredWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter;

- (void)banner_failedToShowAdWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter error:(NSError *)error;

- (void)banner_didAdClickedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter;

- (void)banner_didAdClosedWithAdapter:(id<AdvanceCommonBannerAdapter>)adapter;

@end
