//
//  AdvanceFullScreenVideoDelegate.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
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
