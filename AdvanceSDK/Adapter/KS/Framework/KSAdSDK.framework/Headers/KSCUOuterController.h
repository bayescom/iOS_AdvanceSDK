//
//  KSCUOuterController.h
//  KSAdSDK
//
//  Created by jie cai on 2020/12/9.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSCUOuterController : NSObject

/*
  播放器外部控制能力,需要联系商务申请
 */

  /**
  * 媒体调用，控制当前视频启播或者恢复播放;
  */
- (void)resumeCurrentPlayer;

 /**
  * 媒体调用，控制当前视频暂停播放; 若在首个video起播前调用,视频不启播，若在视频播放过程中调用，视频转变为暂停播放状态。
  */
-  (void)pauseCurrentPlayer;

@end

NS_ASSUME_NONNULL_END
