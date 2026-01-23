//
//  AdvRewardVideoModel.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvRewardVideoModel : NSObject

//app user Identifier
@property (nonatomic, copy, nullable) NSString *userId;

//optional. serialized string.
@property (nonatomic, copy, nullable) NSString *extra;

//reward name.
@property (nonatomic, copy, nullable) NSString *rewardName;

//number of rewards
@property (nonatomic, assign) NSInteger rewardAmount;

@end

NS_ASSUME_NONNULL_END
