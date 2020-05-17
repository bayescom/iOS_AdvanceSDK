//
//  AdvanceRewardVideoProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceRewardVideoProtocol_h
#define AdvanceRewardVideoProtocol_h

#if __has_include(<MercurySDK/AdvanceBaseDelegate.h>)
#import <MercurySDK/AdvanceBaseDelegate.h>
#else
#import "AdvanceBaseDelegate.h"
#endif

@protocol AdvanceRewardVideoDelegate <AdvanceBaseDelegate>
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
- (void)advanceRewardVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
- (void)advanceRewardVideoOnAdClosed;

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective;

/// 激励视频可以调用show方法
- (void)advanceRewardVideoIsReadyToShow;

@end

#endif
