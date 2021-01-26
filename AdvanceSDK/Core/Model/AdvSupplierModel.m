//
//  AdvSupplierModel.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvSupplierModel.h"
#import "AdvDeviceInfoUtil.h"
#import "AdvLog.h"

#define λ(decl, expr) (^(decl) { return (expr); })

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

@interface AdvSupplierModel (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface AdvSetting (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface AdvPriorityMap (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

@interface AdvSupplier (JSONConversion)
+ (instancetype)fromJSONDictionary:(NSDictionary *)dict;
- (NSDictionary *)JSONDictionary;
@end

static id map(id collection, id (^f)(id value)) {
    id result = nil;
    if ([collection isKindOfClass:NSArray.class]) {
        result = [NSMutableArray arrayWithCapacity:[collection count]];
        for (id x in collection) [result addObject:f(x)];
    } else if ([collection isKindOfClass:NSDictionary.class]) {
        result = [NSMutableDictionary dictionaryWithCapacity:[collection count]];
        for (id key in collection) [result setObject:f([collection objectForKey:key]) forKey:key];
    }
    return result;
}

#pragma mark - JSON serialization

AdvSupplierModel *_Nullable AdvSupplierModelFromData(NSData *data, NSError **error)
{
    @try {
        id json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:error];
        return *error ? nil : [AdvSupplierModel fromJSONDictionary:json];
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

AdvSupplierModel *_Nullable AdvSupplierModelFromJSON(NSString *json, NSStringEncoding encoding, NSError **error)
{
    return AdvSupplierModelFromData([json dataUsingEncoding:encoding], error);
}

NSData *_Nullable AdvSupplierModelToData(AdvSupplierModel *supplierModel, NSError **error)
{
    @try {
        id json = [supplierModel JSONDictionary];
        NSData *data = [NSJSONSerialization dataWithJSONObject:json options:kNilOptions error:error];
        return *error ? nil : data;
    } @catch (NSException *exception) {
        *error = [NSError errorWithDomain:@"JSONSerialization" code:-1 userInfo:@{ @"exception": exception }];
        return nil;
    }
}

NSString *_Nullable AdvSupplierModelToJSON(AdvSupplierModel *supplierModel, NSStringEncoding encoding, NSError **error)
{
    NSData *data = AdvSupplierModelToData(supplierModel, error);
    return data ? [[NSString alloc] initWithData:data encoding:encoding] : nil;
}

@implementation AdvSupplierModel

+ (instancetype)loadDataWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    NSString *key = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(AdvSupplierModel.class), mediaId, adspotId];
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if (!dic) {
        return nil;
    }
    AdvSupplierModel *model = [AdvSupplierModel fromJSONDictionary:dic];
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

- (void)save {
//    if (self.suppliers.count > 0) {
        NSString *key = [NSString stringWithFormat:@"%@_%@_%@", NSStringFromClass(AdvSupplierModel.class), self.advMediaId, self.advAdspotId];
        [[NSUserDefaults standardUserDefaults] setObject:[self JSONDictionary] forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
}

+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"setting": @"setting",
        @"suppliers": @"suppliers",
        @"msg": @"msg",
        @"code": @"code",
        @"reqid": @"reqid",
    };
}

+ (_Nullable instancetype)fromData:(NSData *)data error:(NSError *_Nullable *)error
{
    return AdvSupplierModelFromData(data, error);
}

+ (_Nullable instancetype)fromJSON:(NSString *)json encoding:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return AdvSupplierModelFromJSON(json, encoding, error);
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[AdvSupplierModel alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _setting = [AdvSetting fromJSONDictionary:(id)_setting];
        _suppliers = map(_suppliers, λ(id x, [AdvSupplier fromJSONDictionary:x]));
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = AdvSupplierModel.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key
{
    id resolved = AdvSupplierModel.properties[key];
    if (resolved) [super setValue:@(0) forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    @try {
        id dict = [[self dictionaryWithValuesForKeys:AdvSupplierModel.properties.allValues] mutableCopy];
        [dict addEntriesFromDictionary:@{
            @"setting": [_setting JSONDictionary],
            @"suppliers": map(_suppliers, λ(id x, [x JSONDictionary])),
        }];
        
        return dict;
    } @catch (NSException *exception) {
        ADVLog(@"setting or suppliers 为空");
    } @finally {
        
    }
    return nil;
}

- (NSData *_Nullable)toData:(NSError *_Nullable *)error
{
    return AdvSupplierModelToData(self, error);
}

- (NSString *_Nullable)toJSON:(NSStringEncoding)encoding error:(NSError *_Nullable *)error
{
    return AdvSupplierModelToJSON(self, encoding, error);
}
@end

@implementation AdvSetting
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"use_cache": @"useCache",
        @"cache_dur": @"cacheDur",
        @"cpt_start": @"cptStart",
        @"cpt_end": @"cptEnd",
        @"cpt_supplier": @"cptSupplier",
        @"priority_map": @"priorityMap",
        @"parallel_ids": @"parallelIDS",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[AdvSetting alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
        _priorityMap = map(_priorityMap, λ(id x, [AdvPriorityMap fromJSONDictionary:x]));
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = AdvSetting.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key
{
    id resolved = AdvSetting.properties[key];
    if (resolved) [super setValue:@(0) forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:AdvSetting.properties.allValues] mutableCopy];

    // Rewrite property names that differ in JSON
    for (id jsonName in AdvSetting.properties) {
        id propertyName = AdvSetting.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    // Map values that need translation
    [dict addEntriesFromDictionary:@{
        @"priority_map": map(_priorityMap, λ(id x, [x JSONDictionary])),
    }];

    return dict;
}
@end

@implementation AdvPriorityMap
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"supid": @"supid",
        @"priority": @"priority",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[AdvPriorityMap alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = AdvPriorityMap.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key
{
    id resolved = AdvPriorityMap.properties[key];
    if (resolved) [super setValue:@(0) forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    return [self dictionaryWithValuesForKeys:AdvPriorityMap.properties.allValues];
}
@end

@implementation AdvSupplier
+ (NSDictionary<NSString *, NSString *> *)properties
{
    static NSDictionary<NSString *, NSString *> *properties;
    return properties = properties ? properties : @{
        @"sdktag": @"sdktag",
        @"mediakey": @"mediakey",
        @"timeout": @"timeout",
        @"adspotid": @"adspotid",
        @"name": @"name",
        @"imptk": @"imptk",
        @"priority": @"priority",
        @"clicktk": @"clicktk",
        @"loadedtk": @"loadedtk",
        @"mediaid": @"mediaid",
        @"succeedtk": @"succeedtk",
        @"failedtk": @"failedtk",
        @"id": @"identifier",
    };
}

+ (instancetype)fromJSONDictionary:(NSDictionary *)dict
{
    return dict ? [[AdvSupplier alloc] initWithJSONDictionary:dict] : nil;
}

- (instancetype)initWithJSONDictionary:(NSDictionary *)dict
{
    if (self = [super init]) {
        [self setValuesForKeysWithDictionary:dict];
    }
    return self;
}

- (void)setValue:(nullable id)value forKey:(NSString *)key
{
    id resolved = AdvSupplier.properties[key];
    if (resolved) [super setValue:value forKey:resolved];
}

- (void)setNilValueForKey:(NSString *)key
{
    id resolved = AdvSupplier.properties[key];
    if (resolved) [super setValue:@(0) forKey:resolved];
}

- (NSDictionary *)JSONDictionary
{
    id dict = [[self dictionaryWithValuesForKeys:AdvSupplier.properties.allValues] mutableCopy];

    for (id jsonName in AdvSupplier.properties) {
        id propertyName = AdvSupplier.properties[jsonName];
        if (![jsonName isEqualToString:propertyName]) {
            dict[jsonName] = dict[propertyName];
            [dict removeObjectForKey:propertyName];
        }
    }

    return dict;
}

// MARK: ======================= 构建打底渠道 =======================
+ (instancetype)supplierWithMediaId:(NSString *)mediaId
                           adspotId:(NSString *)adspotid
                           mediaKey:(NSString *)mediakey
                              sdkId:(nonnull NSString *)sdkid {
    AdvSupplier *supplier = [[AdvSupplier alloc] init];
    
    supplier.mediaid = mediaId;
    supplier.adspotid = adspotid;
    supplier.mediakey = mediakey;
    supplier.sdktag = @"bottom_default";
    supplier.identifier = sdkid;
    supplier.name = @"打底SDK";
    supplier.priority = 1;
    supplier.timeout = 5000;
    
    [supplier addDefaultSdkSupplierTK];
    
    return supplier;
}

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
