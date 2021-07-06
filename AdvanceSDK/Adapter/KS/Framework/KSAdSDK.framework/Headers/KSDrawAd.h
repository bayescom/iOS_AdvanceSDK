//
//  KSDrawAd.h
//  KSAdSDK
//
//  Created by xuzhijun on 2019/12/6.
//

#import "KSAd.h"

NS_ASSUME_NONNULL_BEGIN

@protocol KSDrawAdDelegate;

@interface KSDrawAd : KSAd


@property (nonatomic, weak) id<KSDrawAdDelegate> delegate;

///手动控制播放|暂停
@property (nonatomic, assign) BOOL controlPlayState;
- (void)registerContainer:(UIView *)containerView;
- (void)unregisterView;
///控制播放暂停，controlPlayState=YES时才生效
- (void)play;
- (void)pause;

@end

@protocol KSDrawAdDelegate <NSObject>
@optional
///广告展示
- (void)drawAdViewWillShow:(KSDrawAd *)drawAd;
///广告点击
- (void)drawAdDidClick:(KSDrawAd *)drawAd;
///广告跳转落地页
- (void)drawAdDidShowOtherController:(KSDrawAd *)drawAd interactionType:(KSAdInteractionType)interactionType;
///广告关闭落地页
- (void)drawAdDidCloseOtherController:(KSDrawAd *)drawAd interactionType:(KSAdInteractionType)interactionType;

///视频开始播放
- (void)drawAdVideoDidStart:(KSDrawAd *)drawAd;
///视频暂停播放
- (void)drawAdVideoDidPause:(KSDrawAd *)drawAd;
///视频恢复播放
- (void)drawAdVideoDidResume:(KSDrawAd *)drawAd;
///视频停止播放，finished=是否播放完成
- (void)drawAdVideoDidStop:(KSDrawAd *)drawAd finished:(BOOL)finished;
///视频播放失败，error=失败原因
- (void)drawAdVideoDidFailed:(KSDrawAd *)drawAd error:(NSError *)error;

@end

NS_ASSUME_NONNULL_END
