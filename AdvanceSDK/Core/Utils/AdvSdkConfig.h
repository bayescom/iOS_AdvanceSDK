//
//  AdvSdkConfig.h
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger,AdvLogLevel) {
    AdvLogLevel_None  = 0, // 不打印
    AdvLogLevel_Fatal,
    AdvLogLevel_Error,
    AdvLogLevel_Warning,
    AdvLogLevel_Info,
    AdvLogLevel_Debug,
};


// MARK: ======================= SDK =======================
extern NSString *const AdvanceSdkAPIVersion;
extern NSString *const AdvanceSdkVersion;
extern NSString *const AdvanceSdkRequestUrl;
extern NSString *const AdvanceReportDataUrl;
extern NSString *const SDK_ID_MERCURY;
extern NSString *const SDK_ID_GDT;
extern NSString *const SDK_ID_CSJ;
extern NSString *const SDK_ID_BAIDU;
extern NSString *const SDK_ID_KS;

//extern NSString *const AdvSdkConfigCAID;
//extern NSString *const AdvSdkConfigCAIDPublicKey;
//extern NSString *const AdvSdkConfigCAIDPublicForApiKey;
//extern NSString *const AdvSdkConfigCAIDDevId;

extern NSString *const AdvSdkTypeAdName;
extern NSString *const AdvSdkTypeAdNameSplash;
extern NSString *const AdvSdkTypeAdNameBanner;
extern NSString *const AdvSdkTypeAdNameInterstitial;
extern NSString *const AdvSdkTypeAdNameFullScreenVideo;
extern NSString *const AdvSdkTypeAdNameNativeExpress;
extern NSString *const AdvSdkTypeAdNameRewardVideo;

extern int const ADVANCE_RECEIVED;
extern int const ADVANCE_ERROR;


@interface AdvSdkConfig : NSObject
/// SDK版本
+ (NSString *)sdkVersion;

+ (instancetype)shareInstance;

/// 是否是Debug
@property(nonatomic) bool isDebug;

/// appid 从平台获取
@property (nonatomic, copy) NSString *appId;

/// 是否允许个性化广告推送 默认为允许
@property (nonatomic, assign) BOOL isAdTrack;


/// 控制台log级别
/// 0 不打印
/// 1 打印fatal
/// 2 fatal + error
/// 3 fatal + error + warning
/// 4 fatal + error + warning + info
/// 5 全部打印
@property (nonatomic, assign) AdvLogLevel level;

// caid设置
//@property (nonatomic, strong) NSDictionary *caidConfig;

@end

NS_ASSUME_NONNULL_END
