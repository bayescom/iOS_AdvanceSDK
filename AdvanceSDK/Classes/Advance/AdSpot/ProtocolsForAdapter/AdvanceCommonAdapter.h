//
//  AdvanceCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "AdvBidWinLossResult.h"
#import "AdvanceCommonSplashAdapterBridge.h"
#import "AdvanceCommonBannerAdapterBridge.h"
#import "AdvanceCommonInterstitialAdapterBridge.h"
#import "AdvanceCommonRewardVideoAdapterBridge.h"
#import "AdvanceCommonFullscreenVideoAdapterBridge.h"
#import "AdvanceCommonNativeExpressAdapterBridge.h"
#import "AdvanceCommonRenderFeedAdapterBridge.h"

#pragma mark: - 广告的adapter基协议
@protocol AdvanceCommonAdapter <NSObject>
@required
/// 加载广告的方法
/// @param placementId adn的广告位ID
/// @param config 广告加载的参数
- (void)adapter_loadAdWithPlacementId:(NSString *)placementId
                               config:(NSDictionary *)config;

@optional
/// 广告是否有效
- (BOOL)adapter_isAdValid;

/// Adn竞胜/竞败后回传信息
- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result;

@end


#pragma mark: - 开屏广告的adapter广告协议
@protocol AdvanceCommonSplashAdapter <AdvanceCommonAdapter>
/// 设置开屏 bridge 用于回传广告状态
- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge;

/// 展示广告
- (void)adapter_showAdInWindow:(UIWindow *)window;

@end


#pragma mark: - Banner广告的adapter广告协议
@protocol AdvanceCommonBannerAdapter <AdvanceCommonAdapter>
/// 设置横幅 bridge 用于回传广告状态
- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge;

/// 提供Adn的广告视图
- (UIView *)adapter_bannerView;

@end


#pragma mark: - 插屏广告的adapter广告协议
@protocol AdvanceCommonInterstitialAdapter <AdvanceCommonAdapter>
/// 设置插屏 bridge 用于回传广告状态
- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge;

/// 展示广告
- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController;

@end


#pragma mark: - 激励视频广告的adapter广告协议
@protocol AdvanceCommonRewardVideoAdapter <AdvanceCommonAdapter>
/// 设置激励视频 bridge 用于回传广告状态
- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge;

/// 展示广告
- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController;

@end


#pragma mark: - 全屏视频广告的adapter广告协议
@protocol AdvanceCommonFullscreenVideoAdapter <AdvanceCommonAdapter>
/// 设置全屏视频 bridge 用于回传广告状态
- (void)adapter_setFullscreenBridge:(id<AdvanceCommonFullscreenVideoAdapterBridge>)bridge;

/// 展示广告
- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController;

@end


#pragma mark: - 信息流（模板渲染）广告的adapter广告协议
@protocol AdvanceCommonNativeExpressAdapter <AdvanceCommonAdapter>
/// 设置信息流 bridge 用于回传广告状态
- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge;

/**
 渲染广告并为广告设置控制器
 如果adn广告不需要render，请尽量模拟回调renderSuccess
 */
- (void)adapter_renderAd:(UIViewController *)viewController;

@end


#pragma mark: - 信息流（自渲染）广告的adapter广告协议
@protocol AdvanceCommonRenderFeedAdapter <AdvanceCommonAdapter>
/// 设置信息流 bridge 用于回传广告状态
- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge;

/// 提供广告包装类信息
- (id)adapter_renderFeedAdWrapper;

@end

