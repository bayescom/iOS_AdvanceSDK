//
//  BdRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardVideoDelegate.h"
#import "AdvBaseAdPosition.h"

@class AdvSupplier;
@class AdvanceRewardVideo;

NS_ASSUME_NONNULL_BEGIN

@interface BdRewardVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
