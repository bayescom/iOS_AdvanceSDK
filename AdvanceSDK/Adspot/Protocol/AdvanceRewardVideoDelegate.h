//
//  AdvanceRewardVideoProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceRewardVideoProtocol_h
#define AdvanceRewardVideoProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceRewardVideoDelegate <AdvanceBaseDelegate>
@optional
/// 广告渲染失败
- (void)advanceRewardVideoOnAdRenderFailed;

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective;

/// 激励视频可以调用show方法
- (void)advanceRewardVideoIsReadyToShow;

#pragma 以下方法已被废弃, 请移步AdvanceBaseDelegate 和 AdvanceCommonDelegate
/// 广告准备完成
//- (void)advanceRewardVideoOnAdReady;

/// 广告曝光
//- (void)advanceRewardVideoOnAdShow;

/// 广告点击
//- (void)advanceRewardVideoOnAdClicked;

/// 广告拉取失败
//- (void)advanceRewardVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
//- (void)advanceRewardVideoOnAdClosed;

@end

#endif
