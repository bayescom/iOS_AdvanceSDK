//
//  AdvanceInterstitialProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceInterstitialProtocol_h
#define AdvanceInterstitialProtocol_h

@protocol AdvanceInterstitialDelegate <NSObject>
@optional

/// 请求广告数据成功后调用
- (void)advanceInterstitialOnAdReceived;

/// 广告曝光成功
- (void)advanceInterstitialOnAdShow;

/// 广告点击
- (void)advanceInterstitialOnAdClicked;

/// 广告渲染失败
- (void)advanceInterstitialOnAdRenderFailed;

/// 广告拉取失败
- (void)advanceInterstitialOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭
- (void)advanceInterstitialOnAdClosed;

/// 广告可以调用show方法
- (void)advanceInterstitialOnReadyToShow;

/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error;

@end

#endif
