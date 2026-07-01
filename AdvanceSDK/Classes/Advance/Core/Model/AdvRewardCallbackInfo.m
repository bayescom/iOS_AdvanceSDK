//
//  AdvRewardCallbackInfo.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/5/7.
//

#import "AdvRewardCallbackInfo.h"

@implementation AdvRewardCallbackInfo

- (instancetype)initWithSourceId:(NSString *)sourceId
                      rewardName:(nullable NSString *)rewardName
                    rewardAmount:(NSInteger)rewardAmount {
    if (self = [super init]) {
        _sourceId = sourceId;
        _rewardName = rewardName;
        _rewardAmount = rewardAmount;
    }
    return self;
}

@end
