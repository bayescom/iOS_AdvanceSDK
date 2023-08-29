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
            return @"AdvanceSdkSupplierRepoLoaded(发起加载请求上报)";
        case AdvanceSdkSupplierRepoClicked:
            return @"AdvanceSdkSupplierRepoClicked(点击上报)";
        case AdvanceSdkSupplierRepoSucceed:
            return @"AdvanceSdkSupplierRepoSucceeded(数据加载成功上报)";
        case AdvanceSdkSupplierRepoImped:
            return @"AdvanceSdkSupplierRepoImped(曝光上报)";
        case AdvanceSdkSupplierRepoFailed:
            return @"AdvanceSdkSupplierRepoFaileded(失败上报)";
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


- (void)setSupplierPrice:(NSInteger)supplierPrice {
    _supplierPrice = supplierPrice;
    if (supplierPrice <= 0) {
        _supplierPrice = self.sdk_price;
    }
}

-(NSInteger)timeout {
    if (!_timeout) {
        return 3000;
    }
    return _timeout;
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
