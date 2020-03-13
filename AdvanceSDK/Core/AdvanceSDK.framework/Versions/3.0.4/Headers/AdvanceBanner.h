//
//  AdvanceBanner.h
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AdvanceBaseAdspot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceBannerDelegate <NSObject>
@optional

/// 请求广告数据成功后调用
- (void)advanceBannerOnAdReceived;

/// 广告曝光回调
- (void)advanceBannerOnAdShow;

/// 广告点击回调
- (void)advanceBannerOnAdClicked;

/// 请求广告数据失败后调用
- (void)advanceBannerOnAdFailed;

/// 广告渲染失败
- (void)advanceBannerOnAdRenderFailed;

/// 广告点击回调
- (void)advanceBannerOnAdClosed;


@end

@interface AdvanceBanner : AdvanceBaseAdspot
@property(nonatomic, weak) UIView *adContainer;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, assign) int refreshInterval;

- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid adContainer:(UIView *)adContainer viewController:(UIViewController *)viewController;
@end

NS_ASSUME_NONNULL_END
