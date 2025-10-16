//
//  AdvanceBanner.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceBannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceBanner : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

/// banner广告视图容器
@property(nonatomic, strong) UIView *adContainer;

/// 渠道要求设置在 30s - 120s
@property(nonatomic, assign) int refreshInterval;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;

/// 构造函数
/// @param adspotid adspotid
/// @param adContainer 广告视图容器
/// @param ext 自定义拓展参数
/// @param viewController viewController
- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
