//
//  CsjRewardVideoAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceRewardVideoDelegate.h"

@class AdvanceRewardVideo;

NS_ASSUME_NONNULL_BEGIN

@interface CsjRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceRewardVideo *)adspot;

- (void)loadAd;

- (void)showAd;

@end

NS_ASSUME_NONNULL_END
