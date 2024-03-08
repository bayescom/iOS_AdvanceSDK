//
//  TanxRewardVideoAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface TanxRewardVideoAdapter : NSObject
@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
