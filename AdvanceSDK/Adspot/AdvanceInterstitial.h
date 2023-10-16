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

/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
