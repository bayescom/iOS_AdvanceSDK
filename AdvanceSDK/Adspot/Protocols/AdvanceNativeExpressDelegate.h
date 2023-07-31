//
//  AdvanceInterstitialDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceNativeExpressDelegate_h
#define AdvanceNativeExpressDelegate_h

#import "AdvanceAdLoadingDelegate.h"
@class AdvanceNativeExpressAd;

@protocol AdvanceNativeExpressDelegate <AdvanceAdLoadingDelegate>

@optional

- (void)didShowNativeExpressAd:(AdvanceNativeExpressAd *_Nullable)nativeAd
                        spotId:(NSString *_Nullable)spotId
                         extra:(NSDictionary *_Nullable)extra;

- (void)dsjkfjgfdkspotId:(NSString *)spotId
                   extra:(NSDictionary *)extra;

/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(nullable NSArray<AdvanceNativeExpressAd *> *)views;

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(nullable AdvanceNativeExpressAd *)adView;

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(nullable AdvanceNativeExpressAd *)adView;

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(nullable AdvanceNativeExpressAd *)adView;

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(nullable AdvanceNativeExpressAd *)adView;

/// 广告被关闭 （百度广告不支持该回调，若使用百青藤，则该回调功能请自行实现）
- (void)advanceNativeExpressOnAdClosed:(nullable AdvanceNativeExpressAd *)adView;

@end

#endif
