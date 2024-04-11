//
//  AdvanceFullScreenVideoDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceFullScreenVideoDelegate_h
#define AdvanceFullScreenVideoDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceFullScreenVideoDelegate <AdvanceAdLoadingDelegate>

@optional

/// Fullscreen video ad loaded successfully
- (void)didFinishLoadingFullscreenVideoADWithSpotId:(NSString *)spotId;

/// Fullscreen video ad local cached
- (void)fullscreenVideoDidDownLoadForSpotId:(NSString *)spotId
                                      extra:(NSDictionary *)extra;

/// Fullscreen video ad play starts
- (void)fullscreenVideoDidStartPlayingForSpotId:(NSString *)spotId
                                          extra:(NSDictionary *)extra;

/// Fullscreen video ad play ends
- (void)fullscreenVideoDidEndPlayingForSpotId:(NSString *)spotId
                                        extra:(NSDictionary *)extra;

/// Fullscreen video ad clicked
- (void)fullscreenVideoDidClickForSpotId:(NSString *)spotId
                                   extra:(NSDictionary *)extra;

/// Fullscreen video ad closed
- (void)fullscreenVideoDidCloseForSpotId:(NSString *)spotId
                                   extra:(NSDictionary *)extra;

/// Fullscreen video ad skiped
- (void)fullscreenVideoDidClickSkipForSpotId:(NSString *)spotId
                                       extra:(NSDictionary *)extra;


@end

#endif
