//
//  AdvanceSplash.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSplash : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;
/// 是否必须展示Logo 默认: NO 注意: 强制展示Logo可能会影响收益 !!!
@property (nonatomic, assign) BOOL showLogoRequire;
/// 广告Logo
@property(nonatomic, strong) UIImage *logoImage;
/// 广告未加载出来时的占位图
@property(nonatomic, strong) UIImage *backgroundImage;
/// 控制器【必传】
@property(nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController DEPRECATED_MSG_ATTRIBUTE("聚合SDK可以直接使用广告位ID初始化");

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
