//
//  AdvanceInterstitialProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceInterstitialProtocol_h
#define AdvanceInterstitialProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceInterstitialDelegate <AdvanceBaseDelegate>
@optional
/// 广告渲染失败
- (void)advanceInterstitialOnAdRenderFailed;

/// 广告可以调用show方法
- (void)advanceInterstitialOnReadyToShow;

#pragma 以下方法已被废弃, 请移步AdvanceBaseDelegate 和 AdvanceCommonDelegate
/// 请求广告数据成功后调用
//- (void)advanceInterstitialOnAdReceived;

/// 广告曝光成功
//- (void)advanceInterstitialOnAdShow;

/// 广告点击
//- (void)advanceInterstitialOnAdClicked;

/// 广告拉取失败
//- (void)advanceInterstitialOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
//- (void)advanceInterstitialOnAdClosed;



@end

#endif
