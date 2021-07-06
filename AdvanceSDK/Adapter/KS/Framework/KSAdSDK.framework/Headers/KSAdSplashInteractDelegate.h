//
//  KSAdSplashInteractDelegate.h
//  Pods
//
//  Created by zhangchuntao on 2020/6/2.
//

#ifndef KSAdSplashInteractDelegate_h
#define KSAdSplashInteractDelegate_h

@protocol KSAdSplashInteractDelegate <NSObject>
@optional
/**
 * 闪屏广告展示
 */
- (void)ksad_splashAdDidShow;
/**
 * 闪屏广告点击转化
 */
- (void)ksad_splashAdClicked;
/**
 * 视频闪屏广告开始播放
 */
- (void)ksad_splashAdVideoDidStartPlay;
/**
 * 视频闪屏广告播放失败
 */
- (void)ksad_splashAdVideoFailedToPlay:(NSError *)error;
/**
 * 视频闪屏广告跳过
 */
- (void)ksad_splashAdVideoDidSkipped:(NSTimeInterval)playDuration;
/**
 * 闪屏广告关闭，需要在这个方法里关闭闪屏页面
 * @param converted      是否转化
 */
- (void)ksad_splashAdDismiss:(BOOL)converted;
/**
 * 转化控制器容器，如果未实现则默认闪屏页面的上级控制器
 */
- (UIViewController *)ksad_splashAdConversionRootVC;

@end

#endif /* KSAdSplashInteractDelegate_h */
