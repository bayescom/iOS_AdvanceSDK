//
//  AdvanceFullScreenVideoDelegate.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceFullScreenVideoDelegate_h
#define AdvanceFullScreenVideoDelegate_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceFullScreenVideoDelegate <AdvanceBaseDelegate>
@optional
/// 视频播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish;



@end

#endif
