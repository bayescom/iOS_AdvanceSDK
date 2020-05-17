//
//  AdvanceSplashProtocol.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#ifndef AdvanceSplashProtocol_h
#define AdvanceSplashProtocol_h

#if __has_include(<MercurySDK/AdvanceBaseDelegate.h>)
#import <MercurySDK/AdvanceBaseDelegate.h>
#else
#import "AdvanceBaseDelegate.h"
#endif

@protocol AdvanceSplashDelegate <AdvanceBaseDelegate>
@optional
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived;

/// 广告曝光成功
- (void)advanceSplashOnAdShow;

/// 广告渲染成功
- (void)advanceSplashOnAdRenderFailed;

/// 广告展示失败
- (void)advanceSplashOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告点击
- (void)advanceSplashOnAdClicked;

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked;

/// 广告倒计时结束回调
- (void)advanceSplashOnAdCountdownToZero;

@end

#endif 
