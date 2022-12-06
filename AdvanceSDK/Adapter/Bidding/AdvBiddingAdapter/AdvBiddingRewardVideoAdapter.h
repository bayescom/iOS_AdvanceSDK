//
//  AdvBiddingRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/8/10.
//

#import "AdvBaseAdPosition.h"
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
//#import "AdvBidding.h"

#import "AdvanceRewardVideoDelegate.h"
@class AdvSupplier;
@class AdvanceRewardVideo;

NS_ASSUME_NONNULL_BEGIN

@interface AdvBiddingRewardVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
