//
//  KSRewardedVideoModel.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/28.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSRewardedVideoModel : NSObject
/**
 required.
 Third-party game user_id identity.
 Mainly used in the reward issuance, it is the callback pass-through parameter from server-to-server.
 It is the unique identifier of each user.
 In the non-server callback mode, it will also be pass-through when the video is finished playing.
 Only the string can be passed in this case, not nil.
 */
@property (nonatomic, copy) NSString *userId;
//optional. reward name.
@property (nonatomic, copy) NSString *name;
//optional. number of rewards.
@property (nonatomic, assign) NSInteger amount;
//optional. serialized string.
@property (nonatomic, copy) NSString *extra;
@end

NS_ASSUME_NONNULL_END
