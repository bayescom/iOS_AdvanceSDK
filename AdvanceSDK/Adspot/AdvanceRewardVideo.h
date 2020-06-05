//
//  AdvanceRewardVideo.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdspot.h"
#import "AdvanceSdkConfig.h"
#import "AdvanceRewardVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceRewardVideo : AdvanceBaseAdspot
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

@property(weak) UIViewController *viewController;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(nonnull UIViewController *)viewController DEPRECATED_MSG_ATTRIBUTE("聚合SDK可以直接使用广告位ID初始化");
- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(nonnull UIViewController *)viewController;
- (void)showAd;

@end

NS_ASSUME_NONNULL_END
