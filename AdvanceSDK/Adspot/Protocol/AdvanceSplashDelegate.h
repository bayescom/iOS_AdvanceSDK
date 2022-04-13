//
//  AdvanceSplashProtocol.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#ifndef AdvanceSplashProtocol_h
#define AdvanceSplashProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceSplashDelegate <AdvanceBaseDelegate>
@optional
/// 广告点击跳过
#pragma 百度广告不支持该回调
- (void)advanceSplashOnAdSkipClicked;

/// 广告倒计时结束回调 百度广告不支持该回调
#pragma 百度广告不支持该回调
- (void)advanceSplashOnAdCountdownToZero;


@end

#endif 
