//
//  KSAdBasePlayerView.h
//  Aspects
//
//  Created by xuzhijun on 2020/2/19.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@class KSAdBasePlayerView;


NS_ASSUME_NONNULL_BEGIN

@protocol KSAdBasePlayerViewDelegate <NSObject>

@optional
// 所有的代理方法均已回到主线程 可直接刷新UI
// 可播放／播放中
- (void)playerViewIsReadyToPlayVideo:(KSAdBasePlayerView *)playerView;
// 播放完毕
- (void)playerViewDidReachEnd:(KSAdBasePlayerView *)playerView;
// 当前播放时间
- (void)playerView:(KSAdBasePlayerView *)playerView currentTime:(CGFloat)currentTime;
// duration 当前缓冲的长度
- (void)playerView:(KSAdBasePlayerView *)playerView loadedTimeRangeDidChange:(CGFloat)duration;
// 进行跳转后没数据 即播放卡顿
- (void)playerViewPlaybackBufferEmpty:(KSAdBasePlayerView *)playerView;
// 进行跳转后有数据 能够继续播放
- (void)playerViewPlaybackLikelyToKeepUp:(KSAdBasePlayerView *)playerView;
// 加载失败
- (void)playerView:(KSAdBasePlayerView *)playerView didFailWithError:(NSError *)error;

@end


@interface KSAdBasePlayerView : UIView

// 默认：AVLayerVideoGravityResizeAspect
@property(nonatomic, copy) AVLayerVideoGravity videoGravity;
@property (nonatomic, copy) void(^__nullable pauseBySystemInterruptBlock)(void);
@property (nonatomic, copy) void(^__nullable resumeBySystemInterruptBlock)(void);

// default = 1.0
@property (nonatomic, assign) CGFloat observerTimeInterval;
// default = NO
@property (nonatomic, assign) BOOL enableVideoCache;
// default = NO
@property (nonatomic, assign) BOOL videoSoundEnable;

#pragma mark - Public

- (BOOL)shouldChangeVideoSoundStatusTo:(BOOL)videoSoundEnable;

// 设置播放URL
- (void)setURL:(NSURL *)URL;
// 指定到某个时间播放
- (void)resumeWithTime:(CGFloat)time;
- (void)seekWithTime:(CGFloat)time;
// 播放
- (void)play;
// 暂停
- (void)pause;
// 停止播放
- (void)stop;
- (void)changeCurrentURLAsset:(AVURLAsset *)urlAsset;

- (void)autoVideoGravity;
- (void)updateVideoGravity:(AVLayerVideoGravity)videoGravity;
// 设置是否开启音量，userForceChange表示用户强制开启或者关闭声音，不受其他app的音频播放影响
- (void)setVideoSoundEnable:(BOOL)videoSoundEnable isUserForceChange:(BOOL)userForceChange;
- (void)updateVolume:(CGFloat)volume;
- (void)replay;
- (void)prepareWithURL:(NSURL *)URL;
//内部参数重置
- (void)resetPlayerParameter;

/// 添加 delegate，支持多个 delegate
- (void)addDelegate:(id<KSAdBasePlayerViewDelegate>)delegate;
/// 删除 delegate
- (void)removeDelegate:(id<KSAdBasePlayerViewDelegate>)delegate;
/// 获取所有 delegates
- (NSArray<id<KSAdBasePlayerViewDelegate>> *)allDelegates;
/// 移除所有 delegates
- (void)removeAllDelegates;

#pragma mark - Readonly
@property (nonatomic, readonly) CGFloat duration;
@property (nonatomic, readonly) CGFloat currentTime;
//播放时为YES 暂停时为NO
@property (nonatomic, readonly) BOOL isPlaying;
// 是否完成
@property (nonatomic, readonly) BOOL isFinish;
@property (nonatomic, readonly) BOOL canPlayOrPause;
@property (nonatomic, readonly) AVURLAsset *urlAsset;

#pragma mark - for subclass
- (void)callDelegates:(void(^)(id<KSAdBasePlayerViewDelegate> delegate))callBlock;

- (void)captureCurrentFrameWithCallback:(void (^)(UIImage * _Nullable currentFrame))callback;

@end

NS_ASSUME_NONNULL_END
