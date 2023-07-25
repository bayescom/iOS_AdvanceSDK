
#ifndef AdvanceRewardVideoProtocol_h
#define AdvanceRewardVideoProtocol_h
#import "AdvanceAdLoadingDelegate.h"
@protocol AdvanceRewardVideoDelegate <AdvanceAdLoadingDelegate>
@optional

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective:(BOOL)isReward;

@end

#endif
