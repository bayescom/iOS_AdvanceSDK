//
//  AdvanceRewardedVideoDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceRewardedVideoDelegate_h
#define AdvanceRewardedVideoDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceRewardedVideoDelegate <AdvanceAdLoadingDelegate>

@optional

/// Rewarded video ad loaded successfully
- (void)didFinishLoadingRewardedVideoADWithSpotId:(NSString *)spotId;

/// Rewarded video ad local cached
- (void)rewardedVideoDidDownLoadForSpotId:(NSString *)spotId
                                    extra:(NSDictionary *)extra;

/// Rewarded video ad play starts
- (void)rewardedVideoDidStartPlayingForSpotId:(NSString *)spotId
                                        extra:(NSDictionary *)extra;

/// Rewarded video ad play ends
- (void)rewardedVideoDidEndPlayingForSpotId:(NSString *)spotId
                                      extra:(NSDictionary *)extra;

/// Rewarded video ad clicked
- (void)rewardedVideoDidClickForSpotId:(NSString *)spotId
                                 extra:(NSDictionary *)extra;

/// Rewarded video ad closed
- (void)rewardedVideoDidCloseForSpotId:(NSString *)spotId
                                 extra:(NSDictionary *)extra;

/// Rewarded video ad reward distribution
- (void)rewardedVideoDidRewardSuccessForSpotId:(NSString *)spotId
                                         extra:(NSDictionary *)extra
                                      rewarded:(BOOL)rewarded;

@end

#endif
