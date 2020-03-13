//
//  MercuryPrerollAdView.h
//  Example
//
//  Created by CherryKing on 2019/12/16.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryEnumHeader.h"

@class MercuryPrerollAdView;
NS_ASSUME_NONNULL_BEGIN

@protocol MercuryPrerollAdDelegate <NSObject>

@optional
/// 贴片广告模型加载成功
- (void)mercury_prerollAdDidReceived;

/// 贴片广告模型加载失败
- (void)mercury_prerollAdFailToReceived:(nullable NSError *)error;

/// 贴片广告曝光失败
/// @param error 异常返回
- (void)mercury_prerollAdFailError:(nullable NSError *)error;

/// 贴片广告曝光回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdExposured:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告点击回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClicked:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告关闭回调
/// @param prerollAd 广告数据
- (void)mercury_prerollAdClosed:(MercuryPrerollAdView *)prerollAd;

/// 贴片广告剩余时间回调
- (void)mercury_prerollAdLifeTime:(NSUInteger)time;

/// 播放状态变更回调
- (void)mercury_prerollAdView:(MercuryPrerollAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end

@interface MercuryPrerollAdView : UIView
/** 在 showSkipTime秒后，曝光跳过按钮
 * 0 表示开始即可跳过
 * 也可设置一个最大值 如 CGFLOAT_MAX 表示不允许跳过
 */
@property (nonatomic, assign) NSTimeInterval showSkipTime;

// 代理
@property (nonatomic, weak) id<MercuryPrerollAdDelegate> delegate;

// 控制器
@property (nonatomic, weak) UIViewController *controller;

/// 是否静音。默认 YES。
@property (nonatomic, assign) BOOL videoMuted;

/// 构造方法
- (instancetype)initWithAdspotId:(NSString *)adspotId;

/// 可自定义跳过按钮
@property (nonatomic, strong) UIView *skipView;

/// 加载并曝光贴片
- (void)loadAd;

/// 曝光视图贴片
- (void)showAdWithView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
