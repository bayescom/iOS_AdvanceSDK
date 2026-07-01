//
//  AdvanceCommonRewardVideoAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/26.
//

@protocol AdvanceCommonRewardVideoAdapter;

/// 激励视频广告adapter的回调协议
@protocol AdvanceCommonRewardVideoAdapterBridge <NSObject>

- (void)rewardVideo_didLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter price:(NSInteger)price;

- (void)rewardVideo_failedToLoadAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error;

- (void)rewardVideo_didAdExposuredWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter;

- (void)rewardVideo_failedToShowAdWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter error:(NSError *)error;

- (void)rewardVideo_didAdClickedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter;

- (void)rewardVideo_didAdClosedWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter;

- (void)rewardVideo_didAdVerifyRewardWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter;// 验证激励回调

- (void)rewardVideo_didAdPlayFinishWithAdapter:(id<AdvanceCommonRewardVideoAdapter>)adapter;

@end
