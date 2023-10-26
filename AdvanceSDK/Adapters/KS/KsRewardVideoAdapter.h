//
//  KsRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface KsRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
