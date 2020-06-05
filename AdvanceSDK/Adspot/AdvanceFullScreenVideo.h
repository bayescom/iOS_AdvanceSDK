//
//  AdvanceFullScreenVideo.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceFullScreenVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceFullScreenVideo : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

@property (nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController DEPRECATED_MSG_ATTRIBUTE("聚合SDK可以直接使用广告位ID初始化");

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController;

- (void)showAd;
@end

NS_ASSUME_NONNULL_END
