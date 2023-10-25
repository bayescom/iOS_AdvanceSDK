//
//  GroMoreRewardedVideoTrigger.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import <Foundation/Foundation.h>
#import "AdvanceRewardedVideoDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroMoreRewardedVideoTrigger : NSObject

@property (nonatomic, weak) id<AdvanceRewardedVideoDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
