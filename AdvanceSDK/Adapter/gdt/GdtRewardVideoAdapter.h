//
//  GdtRewardVideoAdapter.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceRewardVideoDelegate.h"

@class AdvSupplier;
@class AdvanceRewardVideo;

NS_ASSUME_NONNULL_BEGIN

@interface GdtRewardVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
