//
//  AdvanceInterstitial.h
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceBaseAdspot.h"

NS_ASSUME_NONNULL_BEGIN

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
- (void)advanceInterstitialOnAdFailed;

/// 广告关闭
- (void)advanceInterstitialOnAdClosed;

@end

@interface AdvanceInterstitial : AdvanceBaseAdspot
@property(weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
