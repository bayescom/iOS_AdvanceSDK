//
//  AdvanceNativeExpressProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceNativeExpressProtocol_h
#define AdvanceNativeExpressProtocol_h
#import "AdvanceBaseDelegate.h"
@protocol AdvanceNativeExpressDelegate <AdvanceBaseDelegate>
@optional
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(nullable NSArray<UIView *> *)views;

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(nullable UIView *)adView;

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(nullable UIView *)adView;

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(nullable UIView *)adView;

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(nullable UIView *)adView;

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(nullable UIView *)adView;

/// 广告拉取失败
- (void)advanceNativeExpressOnAdFailedWithSdkId:(nullable NSString *)sdkId error:(nullable NSError *)error;

/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error;

@end

#endif
