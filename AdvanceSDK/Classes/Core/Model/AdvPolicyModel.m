//
//  AdvPolicyModel.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 以字符串形式返回状态码
NSString * ADVStringFromNAdvanceSdkSupplierRepoType(AdvanceSdkSupplierRepoType type) {
    switch (type) {
        case AdvanceSdkSupplierRepoLoaded:
            return @"AdvanceSdkSupplierRepoLoaded(广告加载上报)";
        case AdvanceSdkSupplierRepoClicked:
            return @"AdvanceSdkSupplierRepoClicked(广告点击上报)";
        case AdvanceSdkSupplierRepoSucceed:
            return @"AdvanceSdkSupplierRepoSucceeded(广告获取成功上报)";
        case AdvanceSdkSupplierRepoImped:
            return @"AdvanceSdkSupplierRepoImped(广告曝光上报)";
        case AdvanceSdkSupplierRepoFailed:
            return @"AdvanceSdkSupplierRepoFaileded(广告获取/渲染失败上报)";
        case AdvanceSdkSupplierRepoBidWin:
            return @"AdvanceSdkSupplierRepoBidWin(广告竞胜上报)";
        default:
            return @"MercuryBaseAdRepoTKEventTypeUnknow(未知类型上报)";
    }
}

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

-(NSInteger)timeout {
    if (!_timeout) {
        return 3000;
    }
    return _timeout;
}

- (NSString *)supplierKey {
    if (!_supplierKey) {
        _supplierKey = [NSString stringWithFormat:@"%@-%ld",_identifier,_priority];
    }
    return _supplierKey;
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


@implementation Gmtk

@end


@implementation Gromore_params

@end


@implementation Gro_more 

@end



NS_ASSUME_NONNULL_END
