//
//  AdvanceCommonRenderFeedAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/28.
//

@protocol AdvanceCommonRenderFeedAdapter;

/// 自渲染信息流广告adapter的回调协议
@protocol AdvanceCommonRenderFeedAdapterBridge <NSObject>

- (void)renderFeed_didLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter price:(NSInteger)price;

- (void)renderFeed_failedToLoadAdWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter error:(NSError *)error;

- (void)renderFeed_didAdExposuredWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter;

- (void)renderFeed_didAdClickedWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter;

- (void)renderFeed_didAdClosedWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter;

- (void)renderFeed_didAdClosedDetailPageWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter;

- (void)renderFeed_didAdPlayFinishWithAdapter:(id<AdvanceCommonRenderFeedAdapter>)adapter;

@end
