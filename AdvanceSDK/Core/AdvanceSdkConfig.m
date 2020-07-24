//
//  AdvanceSdkConfig.m
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvanceSdkConfig.h"

@interface AdvanceSdkConfig ()
@property (nonatomic, strong) NSDictionary *config;

@end

@implementation AdvanceSdkConfig
NSString *const AdvanceSdkAPIVersion = @"3.0";
NSString *const AdvanceSdkVersion = @"3.2.2.1";
NSString *const AdvanceSdkRequestUrl = @"http://cruiser.bayescom.cn/eleven";
NSString *const AdvanceReportDataUrl = @"http://cruiser.bayescom.cn/native";
NSString *const SDK_ID_MERCURY =@"1";
NSString *const SDK_ID_GDT=@"2";
NSString *const SDK_ID_CSJ=@"3";
NSString *const SDK_ID_BAIDU=@"4";
NSString *const DEFAULT_IMPTK = @"http://cruiser.bayescom.cn/win?action=win&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_CLICKTK = @"http://cruiser.bayescom.cn/click?action=click&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_SUCCEEDTK = @"http://cruiser.bayescom.cn/succeed?action=succeed&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_FAILEDTK = @"http://cruiser.bayescom.cn/failed?action=failed&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";
NSString *const DEFAULT_LOADEDTK = @"http://cruiser.bayescom.cn/loaded?action=loaded&adspotid=__ADSPOTID__&appid=__APPID__&idfa=__IDFA__&os=1&supplierid=__SUPPLIERID__&track_time=__TIME__&auction_id=__AUCTION_ID__&supplier_adspotid=__SUPPLIER_ADSPOT_ID__&is_bottom=1";

int const ADVANCE_RECEIVED = 0;
int const ADVANCE_ERROR = 1;

// MARK: ======================= 穿山甲配置 Key =======================
NSString * const AdvanceSDKConfigBUAppID = @"AdvanceSDKConfigBUAppID";

NSString * const AdvanceSDKConfigBULogLevel = @"AdvanceSDKConfigBULogLevel";

NSInteger const AdvanceSDKConfigBULogLevelNone  = 0;  //BUAdSDKLogLevelNone;
NSInteger const AdvanceSDKConfigBULogLevelError = 1;  //BUAdSDKLogLevelError;
NSInteger const AdvanceSDKConfigBULogLevelDebug = 2;  //BUAdSDKLogLevelDebug;

NSString * const AdvanceSDKConfigBUIsPaidApp = @"AdvanceSDKConfigBUIsPaidApp";
NSString * const AdvanceSDKConfigBUCoppa = @"AdvanceSDKConfigBUCoppa";
NSString * const AdvanceSDKConfigBUUserKeywords = @"AdvanceSDKConfigBUUserKeywords";
NSString * const AdvanceSDKConfigBUUserExtData = @"AdvanceSDKConfigBUUserExtData";

NSString * const AdvanceSDKConfigBUOfflineType = @"AdvanceSDKConfigBUOfflineType";
NSInteger const AdvanceSDKConfigBUOfflineTypeNone       = 0; //BUOfflineTypeNone;
NSInteger const AdvanceSDKConfigBUOfflineTypeProtocol   = 1; //BUOfflineTypeProtocol;
NSInteger const AdvanceSDKConfigBUOfflineTypeWebview    = 2; //BUOfflineTypeWebview;
// MARK: ======================= Mercury配置 Key =======================
NSString * const AdvanceSDKConfigMercuryAppID = @"AdvanceSDKConfigMercuryAppID";
NSString * const AdvanceSDKConfigMercuryMediaKey = @"AdvanceSDKConfigMercuryMediaKey";
NSString * const AdvanceSDKConfigMercuryOpenDebug = @"AdvanceSDKConfigMercuryOpenDebug";
NSString * const AdvanceSDKConfigMercuryOpenRreload = @"AdvanceSDKConfigMercuryOpenRreload";
// MARK: ======================= 广点通配置 Key =======================
NSString * const AdvanceSDKConfigGDTEnableGPS = @"AdvanceSDKConfigGDTEnableGPS";
NSString * const AdvanceSDKConfigGDTChannel = @"AdvanceSDKConfigGDTChannel";
NSString * const AdvanceSDKConfigGDTSdkSrc = @"AdvanceSDKConfigGDTSdkSrc";
NSString * const AdvanceSDKConfigGDTSdkType = @"AdvanceSDKConfigGDTSdkType";
static AdvanceSdkConfig *instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    //dispatch_once （If called simultaneously from multiple threads, this function waits synchronously until the block has completed. 由官方解释，该函数是线程安全的）
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.isDebug = YES;
    });
    return instance;
}

+ (NSString *)sdkVersion {
    return AdvanceSdkVersion;
}

//保证从-alloc-init和-new方法返回的对象是由shareInstance返回的
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [AdvanceSdkConfig shareInstance];
}

//保证从copy获取的对象是由shareInstance返回的
- (id)copyWithZone:(struct _NSZone *)zone {
    return [AdvanceSdkConfig shareInstance];
}

//保证从mutableCopy获取的对象是由shareInstance返回的
- (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [AdvanceSdkConfig shareInstance];
}

- (void)setIsDebug:(bool)isDebug {
    _isDebug = isDebug;
}

@end
