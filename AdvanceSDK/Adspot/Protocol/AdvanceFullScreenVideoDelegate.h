//
//  AdvanceFullScreenVideoDelegate.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceFullScreenVideoDelegate_h
#define AdvanceFullScreenVideoDelegate_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceFullScreenVideoDelegate <AdvanceBaseDelegate>
@optional
/// 视频播放完成
- (void)advanceFullScreenVideoOnAdPlayFinish;

#pragma 以下方法已被废弃, 请移步AdvanceBaseDelegate 和 AdvanceCommonDelegate
/// 请求广告数据成功后调用
//- (void)advanceFullScreenVideoOnAdReceived;

/// 广告曝光成功
//- (void)advanceFullScreenVideoOnAdShow;

/// 广告点击
//- (void)advanceFullScreenVideoOnAdClicked;

/// 广告拉取失败
//- (void)advanceFullScreenVideoOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
//- (void)advanceFullScreenVideoOnAdClosed;




@end

#endif
