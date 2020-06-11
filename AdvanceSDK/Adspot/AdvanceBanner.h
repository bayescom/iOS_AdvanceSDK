//
//  AdvanceBanner.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceBannerDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceBanner : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

@property(nonatomic, weak) UIView *adContainer;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, assign) int refreshInterval;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                    adContainer:(UIView *)adContainer
                 viewController:(UIViewController *)viewController DEPRECATED_MSG_ATTRIBUTE("聚合SDK可以直接使用广告位ID初始化");

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                  viewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
