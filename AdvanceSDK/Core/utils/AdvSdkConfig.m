//
//  AdvSdkConfig.m
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvSdkConfig.h"

@interface AdvSdkConfig ()
@property (nonatomic, strong) NSDictionary *config;

@end

@implementation AdvSdkConfig
NSString *const AdvanceSdkAPIVersion = @"3.0";
NSString *const AdvanceSdkVersion = @"3.2.2.9";
//NSString *const AdvanceSdkRequestUrl = @"http://cruiser.bayescom.cn/eleven";
NSString *const AdvanceSdkRequestUrl = @"https://mock.yonyoucloud.com/mock/2650/api/v3/eleven";
NSString *const AdvanceReportDataUrl = @"http://cruiser.bayescom.cn/native";
NSString *const SDK_ID_MERCURY =@"1";
NSString *const SDK_ID_GDT=@"2";
NSString *const SDK_ID_CSJ=@"3";
NSString *const SDK_ID_BAIDU=@"4";


int const ADVANCE_RECEIVED = 0;
int const ADVANCE_ERROR = 1;

// MARK: ======================= 穿山甲配置 Key =======================
NSString * const AdvSdkConfigBUAppID = @"AdvSdkConfigBUAppID";

NSString * const AdvSdkConfigBULogLevel = @"AdvSdkConfigBULogLevel";

NSInteger const AdvSdkConfigBULogLevelNone  = 0;  //BUAdSDKLogLevelNone;
NSInteger const AdvSdkConfigBULogLevelError = 1;  //BUAdSDKLogLevelError;
NSInteger const AdvSdkConfigBULogLevelDebug = 2;  //BUAdSDKLogLevelDebug;

NSString * const AdvSdkConfigBUIsPaidApp = @"AdvSdkConfigBUIsPaidApp";
NSString * const AdvSdkConfigBUCoppa = @"AdvSdkConfigBUCoppa";
NSString * const AdvSdkConfigBUUserKeywords = @"AdvSdkConfigBUUserKeywords";
NSString * const AdvSdkConfigBUUserExtData = @"AdvSdkConfigBUUserExtData";

NSString * const AdvSdkConfigBUOfflineType = @"AdvSdkConfigBUOfflineType";
NSInteger const AdvSdkConfigBUOfflineTypeNone       = 0; //BUOfflineTypeNone;
NSInteger const AdvSdkConfigBUOfflineTypeProtocol   = 1; //BUOfflineTypeProtocol;
NSInteger const AdvSdkConfigBUOfflineTypeWebview    = 2; //BUOfflineTypeWebview;
// MARK: ======================= Mercury配置 Key =======================
NSString * const AdvSdkConfigMercuryAppID = @"AdvSdkConfigMercuryAppID";
NSString * const AdvSdkConfigMercuryMediaKey = @"AdvSdkConfigMercuryMediaKey";
NSString * const AdvSdkConfigMercuryOpenDebug = @"AdvSdkConfigMercuryOpenDebug";
NSString * const AdvSdkConfigMercuryOpenRreload = @"AdvSdkConfigMercuryOpenRreload";
// MARK: ======================= 广点通配置 Key =======================
NSString * const AdvSdkConfigGDTEnableGPS = @"AdvSdkConfigGDTEnableGPS";
NSString * const AdvSdkConfigGDTChannel = @"AdvSdkConfigGDTChannel";
NSString * const AdvSdkConfigGDTSdkSrc = @"AdvSdkConfigGDTSdkSrc";
NSString * const AdvSdkConfigGDTSdkType = @"AdvSdkConfigGDTSdkType";
static AdvSdkConfig *instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    //dispatch_once （If called simultaneously from multiple threads, this function waits synchronously until the block has completed. 由官方解释，该函数是线程安全的）
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.isDebug = NO;
    });
    return instance;
}

+ (NSString *)sdkVersion {
    return AdvanceSdkVersion;
}

//保证从-alloc-init和-new方法返回的对象是由shareInstance返回的
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

//保证从copy获取的对象是由shareInstance返回的
- (id)copyWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

//保证从mutableCopy获取的对象是由shareInstance返回的
- (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

- (void)setIsDebug:(bool)isDebug {
    _isDebug = isDebug;
}

@end