//
//  AdvanceInterstitial.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvBaseAdapter.h"

#import <UIKit/UIKit.h>

#import "AdvSdkConfig.h"
#import "AdvanceInterstitialDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceInterstitial : AdvBaseAdapter
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, assign, readonly) CGSize adSize;



- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)adSize;


/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
/// @param adSize 广告素材的期望尺寸, 仅部分支持, 渠道也只是会返回近似尺寸的素材,不会严格按照传入的尺寸展示
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(NSDictionary *_Nonnull)ext
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)adSize;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
