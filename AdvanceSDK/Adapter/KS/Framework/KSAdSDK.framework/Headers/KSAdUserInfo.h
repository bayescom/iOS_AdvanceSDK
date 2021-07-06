//
//  KSAdUserInfo.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KSAdUserInfo : NSObject

@property (nonatomic, assign) long userId;           // 用户id，目前是必填
@property (nonatomic, copy) NSString *thirdUserId;      //媒体用户id，目前用在激励视频回调
@property (nonatomic, copy) NSString *gender;         // 用户性别，选填 F: 女性 M:男性
@property (nonatomic, copy) NSArray *interestArray;   // 用户兴趣，选填
@end

NS_ASSUME_NONNULL_END
