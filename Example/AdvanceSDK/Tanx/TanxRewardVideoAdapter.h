//
//  TanxRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by MS on 2022/7/15.
//

#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
