//
//  AdvPolicyModel.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - Private model interfaces


@implementation AdvPolicyModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"suppliers" : [AdvSupplier class]};
}

@end

@implementation AdvSupplier

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"identifier": @"id",
        @"bidRatio": @"bid_ratio",
    };
}

- (NSInteger)timeout {
    if (!_timeout) {
        return 3000;
    }
    return _timeout;
}

- (NSInteger)cache_timeout {
    if (_enable_cache && !_cache_timeout) {
        return 1800;
    }
    return _cache_timeout;
}

@end

@implementation AdvSetting
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"useCache": @"use_cache",
        @"cacheDur": @"cache_dur",
        @"parallelGroup": @"parallel_group",
        @"headBiddingGroup": @"head_bidding_group",
    };
}

- (NSInteger)parallel_timeout {
    if (!_parallel_timeout) {
        return 5000;
    }
    return _parallel_timeout;
}

@end

@implementation ServerReward

@end


@implementation Gmtk

@end


@implementation Gromore_params

@end


@implementation Gro_more 

@end



NS_ASSUME_NONNULL_END
