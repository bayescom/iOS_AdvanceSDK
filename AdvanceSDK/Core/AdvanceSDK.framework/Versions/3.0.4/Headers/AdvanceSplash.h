//
//  AdvanceSplash.h
//  advancelib
//
//  Created by allen on 2019/10/15.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "AdvanceBaseAdspot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceSplashDelegate <NSObject>
@optional
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived;

/// 广告曝光成功
- (void)advanceSplashOnAdShow;

/// 广告渲染成功
- (void)advanceSplashOnAdRenderFailed;

/// 广告展示失败
- (void)advanceSplashOnAdFailed;

/// 广告点击
- (void)advanceSplashOnAdClicked;

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked;

/// 广告倒计时结束回调
- (void)advanceSplashOnAdCountdownToZero;

@end

@interface AdvanceSplash : AdvanceBaseAdspot
/// 广告Logo
@property(nonatomic, strong) UIImage *logoImage;
/// 广告未加载出来时的占位图
@property(nonatomic, strong) UIImage *backgroundImage;
/// 控制器【必传】
@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
