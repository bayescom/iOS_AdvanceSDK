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

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param ext 自定义拓展参数
/// @param viewController 广告加载容器 （建议传入当前控制器，广告需要提前加载可传nil）
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(nullable UIViewController *)viewController;

/// 加载广告
- (void)loadAd;

/// 初始化已传入viewController，展示广告可使用此方法
- (void)showAd;

/// 初始化未传入viewController，展示广告必须使用此方法
- (void)showAdFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
