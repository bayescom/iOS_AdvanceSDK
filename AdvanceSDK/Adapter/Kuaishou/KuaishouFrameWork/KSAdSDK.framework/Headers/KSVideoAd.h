//
//  KSVideoAd.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/9/4.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "KSAd.h"
#import "KSAdShowDirection.h"

NS_ASSUME_NONNULL_BEGIN

@interface KSVideoAd : KSAd

@property (nonatomic, readonly) BOOL isValid;
@property (nonatomic, assign) BOOL shouldMuted;
@property (nonatomic, assign) KSAdShowDirection showDirection;  //显示方向

- (void)loadAdData;

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController direction:(KSAdShowDirection)direction DEPRECATED_ATTRIBUTE;

- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(nullable NSString *)showScene;
- (BOOL)showAdFromRootViewController:(UIViewController *)rootViewController showScene:(nullable NSString *)showScene direction:(KSAdShowDirection)direction DEPRECATED_ATTRIBUTE;

/*
 这个是播放异常的时候,此方法不会自动调用，可以在
 - (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error使用此方法
 */
- (void)closeVideoAdWhenPlayError;

// 是否是同一个有效广告
- (BOOL)isSameValidVideoAd:(nullable KSVideoAd *)ad;

@end

NS_ASSUME_NONNULL_END
