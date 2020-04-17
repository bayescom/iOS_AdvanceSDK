//
//  AdvanceRewardVideoProtocol.h
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceRewardVideoProtocol_h
#define AdvanceRewardVideoProtocol_h

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
- (void)advanceRewardVideoOnAdFailedWithAdapterId:(NSString *)adapterId error:(NSError *)error;

/// 广告关闭
- (void)advanceRewardVideoOnAdClosed;

/// 广告视频缓存完成
- (void)advanceRewardVideoOnAdVideoCached;

/// 广告视频播放完成
- (void)advanceRewardVideoAdDidPlayFinish;

/// 广告到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective;

@end

#endif
