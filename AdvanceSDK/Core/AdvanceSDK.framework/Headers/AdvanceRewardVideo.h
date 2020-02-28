//
//  AdvanceRewardVideo.h
//  AdvanceSDK
//
//  Created by 程立卿 on 2020/1/3.
//  Copyright © 2020 BAYESCOM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdvanceBaseAdspot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceRewardVideoDelegate <NSObject>
@optional

/// 广告准备完成
- (void)advanceRewardVideoOnAdReady;

/// 广告曝光
- (void)advanceRewardVideoOnAdShow;

/// 广告点击
- (void)advanceRewardVideoOnAdClicked;

/// 广告渲染失败
- (void)advanceRewardVideoOnAdRenderFailed;

/// 广告拉取失败
- (void)advanceRewardVideoOnAdFailed;

/// 广告关闭
- (void)advanceRewardVideoOnAdClosed;

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective;

@end

@interface AdvanceRewardVideo : AdvanceBaseAdspot
@property(weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
