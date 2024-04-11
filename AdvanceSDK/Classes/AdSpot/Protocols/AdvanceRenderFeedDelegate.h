//
//  AdvanceRenderFeedDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#ifndef AdvanceRenderFeedDelegate_h
#define AdvanceRenderFeedDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@class AdvRenderFeedAd;

@protocol AdvanceRenderFeedDelegate <AdvanceAdLoadingDelegate>

@optional

/// RenderFeed ad loaded successfully
- (void)didFinishLoadingRenderFeedAd:(AdvRenderFeedAd *)feedAd
                              spotId:(NSString *)spotId;

/// RenderFeed ad displayed successfully
- (void)renderFeedAdDidShowForSpotId:(NSString *)spotId
                               extra:(NSDictionary *)extra;

/// RenderFeed ad clicked
- (void)renderFeedAdDidClickForSpotId:(NSString *)spotId
                                extra:(NSDictionary *)extra;

/// RenderFeed ad closed
- (void)renderFeedAdDidCloseForSpotId:(NSString *)spotId
                                extra:(NSDictionary *)extra;

/// Ad detail page closed
- (void)renderFeedAdDidCloseDetailPageForSpotId:(NSString *)spotId
                                          extra:(NSDictionary *)extra;

/// RenderFeed video ad ends playing
- (void)renderFeedVideoDidEndPlayingForSpotId:(NSString *)spotId
                                        extra:(NSDictionary *)extra;

@end

#endif


