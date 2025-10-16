//
//  AdvanceRewardVideo.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceRewardedVideoDelegate.h"
#import "AdvRewardedVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceRewardVideo : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

/// 设定是否静音播放视频，默认为YES
@property (nonatomic, assign) BOOL muted;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;

/// 奖励信息
@property (nonatomic, strong) AdvRewardedVideoModel *rewardedVideoModel;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param ext 自定义拓展参数
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext;


/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showAdFromViewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
