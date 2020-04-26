//
//  AdvanceInterstitialProtocol.h
//  AdvanceSDKDev
//
//  Created by 程立卿 on 2020/4/9.
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

@end

#endif
