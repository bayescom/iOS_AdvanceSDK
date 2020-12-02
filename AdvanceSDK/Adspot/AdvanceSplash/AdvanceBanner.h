//
//  AdvanceBanner.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvBaseAdapter.h"
#import "AdvSdkConfig.h"
#import "AdvanceBannerDelegate.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceBanner : AdvBaseAdapter
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

@property(nonatomic, weak) UIView *adContainer;
@property(nonatomic, weak) UIViewController *viewController;
@property(nonatomic, assign) int refreshInterval;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                  viewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END