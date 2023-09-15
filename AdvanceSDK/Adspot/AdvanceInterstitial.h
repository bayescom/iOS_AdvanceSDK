//
//  AdvanceInterstitial.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceInterstitial : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

/// 素材尺寸
@property (nonatomic, assign) CGSize adSize;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
/// @param adSize 广告素材的期望尺寸, 仅部分支持, 渠道也只是会返回近似尺寸的素材,不会严格按照传入的尺寸展示
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)adSize;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)adSize;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
