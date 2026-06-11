#import "AdvanceBaseAdSpot.h"
#import "AdvLog.h"
#import "AdvPolicyService.h"
#import "AdvConstantHeader.h"
#import "AdvanceCommonConfigAdapter.h"
#import "AdvCustomAdnCacheManager.h"

@interface AdvanceBaseAdSpot () <AdvPolicyServiceDelegate>

@end

@implementation AdvanceBaseAdSpot

@synthesize adspotid = _adspotid;
@synthesize reqId = _reqId;
@synthesize extraDict = _extraDict;
@synthesize adapterMap = _adapterMap;
@synthesize targetAdapter = _targetAdapter;
@synthesize manager = _manager;
@synthesize suppliers = _suppliers;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    if (self = [super init]) {
        _adspotid = adspotid;
        _extraDict = [extra mutableCopy];
        _reqId = [AdvDeviceManager getUUID];
        _manager = [AdvPolicyService manager];
        ((AdvPolicyService *)_manager).delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
        _suppliers = [NSMutableArray array];
        [self setupAllSDKVersion];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadPolicyDataWithAdspotId:_adspotid reqId:_reqId extra:_extraDict.copy];
}

- (void)destroyAdapters {
    self.adapterMap = nil;
    self.manager = nil;
}

- (void)setupAllSDKVersion {
    [self setGDTSDKVersion];
    [self setCSJSDKVersion];
    [self setMercurySDKVersion];
    [self setKSSDKVersion];
    [self setBaiduSDKVersion];
    [self setTanxSDKVersion];
    [self setSigmobSDKVersion];
    [self setFunlinkSDKVersion];
    [self setCustomAdnVersion];
}

- (void)setGDTSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_GDT];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"gdt_v"];
    }
}

- (void)setCSJSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_CSJ];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"csj_v"];
    }
}

- (void)setMercurySDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_MERCURY];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"mry_v"];
    }
}

- (void)setKSSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_KS];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"ks_v"];
    }
}

- (void)setBaiduSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_BAIDU];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"bd_v"];
    }
}

- (void)setTanxSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_TANX];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"tanx_v"];
    }
}

- (void)setSigmobSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_Sigmob];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"sig_v"];
    }
}

- (void)setFunlinkSDKVersion {
    NSString *configClass = [AdvSupplierLoader mappingConfigAdapterNameWithSupplierId:SDK_ID_Funlink];
    Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(configClass);
    if ([clazz respondsToSelector:@selector(sdkVersion)]) {
        NSString *version = [clazz sdkVersion];
        [_extraDict adv_safeSetObject:version forKey:@"flink_v"];
    }
}

- (void)setCustomAdnVersion {
    // 从缓存中获取adnlist信息
    AdvCustomAdnListInfo *cacheInfo = [[AdvCustomAdnCacheManager sharedInstance] customAdnlistInfo];
    if (cacheInfo.custom_adn_list.count) {
        [cacheInfo.custom_adn_list enumerateObjectsUsingBlock:^(AdvCustomAdnModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            Class<AdvanceCommonConfigAdapter> clazz = NSClassFromString(obj.customConfigAdapterClassName);
            if ([clazz respondsToSelector:@selector(sdkVersion)]) {
                NSString *version = [clazz sdkVersion];
                [_extraDict adv_safeSetObject:version forKey:[NSString stringWithFormat:@"%@_v", obj.adnTag]];
            }
        }];
    }
}

- (void)dealloc {
    
}

@end
