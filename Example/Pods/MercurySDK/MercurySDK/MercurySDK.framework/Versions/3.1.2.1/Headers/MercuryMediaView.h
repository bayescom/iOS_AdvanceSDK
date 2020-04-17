//
//  MercuryMediaView.h
//  Example
//
//  Created by CherryKing on 2019/12/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MercuryMediaView;
@protocol MercuryMediaViewDelegate <NSObject>

@optional

/**
 用户点击 MediaView 回调，当 MercuryVideoConfig userControlEnable 设为 YES，用户点击 mediaView 会回调。
 
 @param mediaView 播放器实例
 */
- (void)mercury_mediaViewDidTapped:(MercuryMediaView *)mediaView;

/**
 播放完成回调

 @param mediaView 播放器实例
 */
- (void)mercury_mediaViewDidPlayFinished:(MercuryMediaView *)mediaView;

@end

@interface MercuryMediaView : UIView

/// MercuryMediaView 回调对象
@property (nonatomic, weak) id <MercuryMediaViewDelegate> delegate;

/// 视频广告时长，单位 ms
@property (nonatomic, assign, readonly) NSTimeInterval videoDuration;

/// 视频广告已播放时长，单位 ms
@property (nonatomic, assign, readonly) NSTimeInterval videoPlayTime;

/// 播放视频
- (void)play;

/// 暂停视频，调用 pause 后，需要被暂停的视频广告对象，不会再自动播放，需要调用 play 才能恢复播放。
- (void)pause;

/// 停止播放，并展示第一帧
- (void)stop;

@end

NS_ASSUME_NONNULL_END
