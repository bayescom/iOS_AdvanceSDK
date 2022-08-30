//
//  AdvSupplierModel.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvSupplierModel.h"
#import "AdvDeviceInfoUtil.h"
#import "AdvLog.h"
#import "AdvModel.h"

NS_ASSUME_NONNULL_BEGIN

/// 以字符串形式返回状态码
NSString * ADVStringFromNAdvanceSdkSupplierRepoType(AdvanceSdkSupplierRepoType type) {
    switch (type) {
        case AdvanceSdkSupplierRepoLoaded:
            return @"AdvanceSdkSupplierRepoLoaded(发起加载请求上报)";
        case AdvanceSdkSupplierRepoClicked:
            return @"AdvanceSdkSupplierRepoClicked(点击上报)";
        case AdvanceSdkSupplierRepoSucceeded:
            return @"AdvanceSdkSupplierRepoSucceeded(数据加载成功上报)";
        case AdvanceSdkSupplierRepoImped:
            return @"AdvanceSdkSupplierRepoImped(曝光上报)";
        case AdvanceSdkSupplierRepoFaileded:
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


@implementation AdvSupplierModel

+ (instancetype)loadDataWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(AdvSupplierModel.class), mediaId, adspotId];
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!data) {
        return nil;
    }
    AdvSupplierModel *model = [AdvSupplierModel adv_modelWithJSON:data];
    if (model) {
        model.advMediaId = mediaId;
        model.advAdspotId = adspotId;
    }
    return model;
}

- (void)clearLocalModel {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(AdvSupplierModel.class), self.advMediaId, self.advAdspotId];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveData:(NSData *)data{
//    if (self.suppliers.count > 0) {
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(AdvSupplierModel.class), self.advMediaId, self.advAdspotId];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}


+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"suppliers" : [AdvSupplier class]};
}


@end

@implementation AdvSetting
+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"useCache": @"use_cache",
        @"cacheDur": @"cache_dur",
        @"cptStart": @"cpt_start",
        @"cptEnd": @"cpt_end",
        @"cptSupplier": @"cpt_supplier",
        @"priorityMap": @"priority_map",
        @"parallelIDS": @"parallel_ids",
        @"parallelGroup": @"parallel_group",
        @"headBiddingGroup": @"head_bidding_group",
    };
}
@end

@implementation AdvBiddingModel

@end



@implementation AdvSupplier

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{
        @"identifier": @"id",
    };
}


- (void)setSupplierPrice:(NSInteger)supplierPrice {
    _supplierPrice = supplierPrice;
    if (supplierPrice == 0) {
        _supplierPrice = self.sdk_price;
    }
}

// MARK: ======================= 构建打底渠道 =======================
//+ (instancetype)supplierWithMediaId:(NSString *)mediaId
//                           adspotId:(NSString *)adspotid
//                           mediaKey:(NSString *)mediakey
//                              sdkId:(nonnull NSString *)sdkid {
//    AdvSupplier *supplier = [[AdvSupplier alloc] init];
//    
//    supplier.mediaid = mediaId;
//    supplier.adspotid = adspotid;
//    supplier.mediakey = mediakey;
//    supplier.sdktag = @"bottom_default";
//    supplier.identifier = sdkid;
//    supplier.name = @"打底SDK";
//    supplier.priority = 1;
//    supplier.timeout = 5000;
//
//    [supplier addDefaultSdkSupplierTK];
//
//    return supplier;
//}

- (void)addDefaultSdkSupplierTK {
    NSString *idfa = [AdvDeviceInfoUtil getIdfa];
    NSString *auctionId= [AdvDeviceInfoUtil getAuctionId];
    self.imptk      = [[[NSMutableArray alloc] init] arrayByAddingObject:
                       [self constructDefaultTk:DEFAULT_IMPTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.identifier auctionId:auctionId supplierAdspotId:self.adspotid]];
    self.succeedtk  = [[[NSMutableArray alloc] init] arrayByAddingObject:
                       [self constructDefaultTk:DEFAULT_SUCCEEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.identifier auctionId:auctionId supplierAdspotId:self.adspotid]];
    self.clicktk    = [[[NSMutableArray alloc] init] arrayByAddingObject:
                       [self constructDefaultTk:DEFAULT_CLICKTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.identifier auctionId: auctionId supplierAdspotId:self.adspotid]];
    self.failedtk   = [[[NSMutableArray alloc] init] arrayByAddingObject:
                       [self constructDefaultTk:DEFAULT_FAILEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.identifier auctionId:auctionId supplierAdspotId:self.adspotid]];
    self.loadedtk   = [[[NSMutableArray alloc] init] arrayByAddingObject:
                       [self constructDefaultTk:DEFAULT_LOADEDTK withAppId:self.mediaid adspotId:self.adspotid idfa:idfa supplierId:self.identifier auctionId:auctionId supplierAdspotId:self.adspotid]];
}

- (NSString *)constructDefaultTk:(NSString *)url withAppId:(NSString *)appid adspotId:(NSString *)adspotid idfa:(NSString *)idfa
                      supplierId:(NSString *)supplierid auctionId:(NSString*)auctionId supplierAdspotId:(NSString*) supplierAdspotId {
    @try {
        NSString *url2 = [url stringByReplacingOccurrencesOfString:@"__ADSPOTID__" withString:self.adspotid];
        NSString *url3 = [url2 stringByReplacingOccurrencesOfString:@"__APPID__" withString:self.mediaid];
        NSString *url4 = [url3 stringByReplacingOccurrencesOfString:@"__IDFA__" withString:idfa];
        NSString *url5 = [url4 stringByReplacingOccurrencesOfString:@"__SUPPLIERID__" withString:supplierid];
        NSString *url6 = [url5 stringByReplacingOccurrencesOfString:@"__AUCTION_ID__" withString:auctionId];
        NSString *url7 = [url6 stringByReplacingOccurrencesOfString:@"__SUPPLIER_ADSPOT_ID__" withString:supplierAdspotId];
        return url7;
    }
    @catch (NSException *e) {
        return url;
    }
}

@end

NS_ASSUME_NONNULL_END
