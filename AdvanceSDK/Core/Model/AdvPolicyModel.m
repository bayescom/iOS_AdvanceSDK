//
//  AdvSupplierModel.m
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

NSString *const DEFAULT_IMPTK = @"http://cruiser.bayescom.cn/win?action=win&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_CLICKTK = @"http://cruiser.bayescom.cn/click?action=click&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_SUCCEEDTK = @"http://cruiser.bayescom.cn/succeed?action=succeed&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_FAILEDTK = @"http://cruiser.bayescom.cn/failed?action=failed&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_LOADEDTK = @"http://cruiser.bayescom.cn/loaded?action=loaded&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";

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
        @"enableBidding": @"is_head_bidding"
    };
}


- (void)setSupplierPrice:(NSInteger)supplierPrice {
    _supplierPrice = supplierPrice;
    if (supplierPrice == 0 || supplierPrice == -1) {
        _supplierPrice = self.sdk_price;
    }
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
@end


@implementation Gmtk


@end


@implementation Gromore_params

@end


@implementation Gro_more 

@end



NS_ASSUME_NONNULL_END
