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
/// 视频播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish;
- (void)advanceFullScreenVideodDidClickSkip;
- (void)advanceFullScreenVideoOnAdVideoCached;


@end

#endif
