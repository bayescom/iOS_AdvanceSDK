//
//  KsRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardedVideoDelegate.h"
#import "AdvanceBaseAdapter.h"
NS_ASSUME_NONNULL_BEGIN
@class AdvSupplier;
@class AdvanceRewardVideo;

@interface KsRewardVideoAdapter : AdvanceBaseAdapter
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
