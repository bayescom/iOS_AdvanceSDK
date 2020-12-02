//
//  AdvanceFullScreenVideo.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvBaseAdapter.h"

#import <UIKit/UIKit.h>

#import "AdvSdkConfig.h"
#import "AdvanceFullScreenVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceFullScreenVideo : AdvBaseAdapter
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

@property (nonatomic, weak) UIViewController *viewController;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController;

- (void)showAd;
@end

NS_ASSUME_NONNULL_END
