//
//  BdRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface BdRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
