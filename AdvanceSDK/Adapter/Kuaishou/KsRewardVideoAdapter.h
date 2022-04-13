//
//  KsRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardVideoDelegate.h"
#import "AdvBaseAdPosition.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceRewardVideo;

@interface KsRewardVideoAdapter : AdvBaseAdPosition
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
