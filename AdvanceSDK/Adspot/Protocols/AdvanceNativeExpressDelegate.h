//
//  AdvanceNativeExpressDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceNativeExpressDelegate_h
#define AdvanceNativeExpressDelegate_h
#import "AdvanceAdLoadingDelegate.h"
@class AdvanceNativeExpressView;
@protocol AdvanceNativeExpressDelegate <AdvanceAdLoadingDelegate>
@optional
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(nullable NSArray<AdvanceNativeExpressView *> *)views;

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(nullable AdvanceNativeExpressView *)adView;

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(nullable AdvanceNativeExpressView *)adView;

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(nullable AdvanceNativeExpressView *)adView;

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(nullable AdvanceNativeExpressView *)adView;

/// 广告被关闭 (注: 百度广告(百青藤), 不支持该回调, 若使用百青藤,则该回到功能请自行实现)
- (void)advanceNativeExpressOnAdClosed:(nullable AdvanceNativeExpressView *)adView;

@end

#endif
