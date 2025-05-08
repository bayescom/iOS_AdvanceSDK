//
//  AdvRewardCallbackInfo.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/5/7.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvRewardCallbackInfo : NSObject
@property (nonatomic, copy) NSString *sourceId; // SDK渠道Id
@property (nonatomic, copy) NSString *rewardName; // 激励名称
@property (nonatomic, assign) NSInteger rewardAmount; // 激励数量

- (instancetype)initWithSourceId:(NSString *)sourceId
                      rewardName:(nullable NSString *)rewardName
                    rewardAmount:(NSInteger)rewardAmount;

@end

NS_ASSUME_NONNULL_END
