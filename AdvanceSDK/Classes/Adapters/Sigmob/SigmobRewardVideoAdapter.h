//
//  SigmobRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/17.
//

#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface SigmobRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
