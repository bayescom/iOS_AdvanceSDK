//
//  AdvanceAdInfo.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/14.
//

#import "AdvanceAdInfo.h"

@implementation AdvanceAdInfo

@end


@implementation AdvRewardVideoModel

@end


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


@implementation AdvBidWinLossResult

- (instancetype)initWithBidResultType:(AdvBidWinLossResultType)bidResultType winPrice:(NSInteger)winPrice secondPrice:(NSInteger)secondPrice {
    if (self = [super init]) {
        self.bidResultType = bidResultType;
        self.winPrice = winPrice;
        self.secondPrice = secondPrice;
    }
    return self;
}

@end
