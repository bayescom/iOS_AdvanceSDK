//
//  AdvanceRewardVideo.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvBaseAdapter.h"

#import <UIKit/UIKit.h>

#import "AdvSdkConfig.h"
#import "AdvanceRewardVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceRewardVideo : AdvBaseAdapter
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

@property(weak) UIViewController *viewController;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(nonnull UIViewController *)viewController;
- (void)showAd;

@end

NS_ASSUME_NONNULL_END
