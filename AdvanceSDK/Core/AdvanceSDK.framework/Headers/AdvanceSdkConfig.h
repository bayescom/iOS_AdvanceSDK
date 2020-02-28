//
//  AdvanceSdkConfig.h
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: ======================= 穿山甲配置 Key =======================
/// 穿山甲 AppID [如要使用穿山甲，必填]
extern NSString * const AdvanceSDKConfigBUAppID;
/**
 * 穿山甲 日志级别 默认：AdvanceSDKConfigBULogLevelNone
 * AdvanceSDKConfigBULogLevelNone
 * AdvanceSDKConfigBULogLevelDebug
 * AdvanceSDKConfigBULogLevelError
 */
extern NSString * const AdvanceSDKConfigBULogLevel;

extern NSInteger const AdvanceSDKConfigBULogLevelNone;
extern NSInteger const AdvanceSDKConfigBULogLevelError;
extern NSInteger const AdvanceSDKConfigBULogLevelDebug;

/** 穿山甲 Set the COPPA of the user, COPPA is the short of Children's Online Privacy Protection Rule, the interface only works in the United States.
 *  Coppa 0 adult, 1 child
 */
extern NSString * const AdvanceSDKConfigBUCoppa;
/// 穿山甲 设置用户的关键字，例如兴趣和爱好等。 [注意]传入之前必须征得用户的同意。
extern NSString * const AdvanceSDKConfigBUUserKeywords;
/// 穿山甲 设置其他用户信息。
extern NSString * const AdvanceSDKConfigBUUserExtData;

/**
 * 穿山甲 解决WKWebview发布消息为空时的问题，默认为BUOfflineTypeWebview
 * AdvanceSDKConfigBULogLevelNone
 * AdvanceSDKConfigBULogLevelDebug
 * AdvanceSDKConfigBULogLevelError
*/
extern NSString * const AdvanceSDKConfigBUOfflineType;

extern NSInteger const AdvanceSDKConfigBUOfflineTypeNone;       // Do not set offline
extern NSInteger const AdvanceSDKConfigBUOfflineTypeProtocol;   // Offline dependence NSURLProtcol
extern NSInteger const AdvanceSDKConfigBUOfflineTypeWebview;    // Offline dependence WKWebview

/// 穿山甲 是否是 paid app
extern NSString * const AdvanceSDKConfigBUIsPaidApp;

// MARK: ======================= Mercury配置 Key =======================
/// Mercury AppID [如要使用Mercury，必填]
extern NSString * const AdvanceSDKConfigMercuryAppID;
/// Mercury MediaKey [如要使用Mercury，必填]
extern NSString * const AdvanceSDKConfigMercuryMediaKey;

/// Mercury 是否开启日志打印，默认 NO
extern NSString * const AdvanceSDKConfigMercuryOpenDebug;
// MARK: ======================= 广点通配置 Key =======================
/// 广点通 是否开启GPS
extern NSString * const AdvanceSDKConfigGDTEnableGPS;
/// 广点通 提供给聚合平台用来设定SDK 流量分类
extern NSString * const AdvanceSDKConfigGDTSdkSrc;
/// 广点通 SdkType
extern NSString * const AdvanceSDKConfigGDTSdkType;

/// 广点通 设置广点通渠道id
//    1：百度
//    2：头条
//    3：广点通
//    4：搜狗
//    5：其他网盟
//    6：oppo
//    7：vivo
//    8：华为
//    9：应用宝
//    10：小米
//    11：金立
//    12：百度手机助手
//    13：魅族
//    14：AppStore
//    999：其他
extern NSString * const AdvanceSDKConfigGDTChannel;
// MARK: ======================= SDK =======================
extern NSString *const AdvanceSdkVersion;
extern NSString *const AdvanceSdkRequestUrl;
extern NSString *const AdvanceReportDataUrl;
extern NSString *const SDK_TAG_MERCURY;
extern NSString *const SDK_TAG_GDT;
extern NSString *const SDK_TAG_CSJ;
extern NSString *const DEFAULT_IMPTK;
extern NSString *const DEFAULT_CLICKTK;
extern NSString *const DEFAULT_SUCCEEDTK;
extern NSString *const DEFAULT_FAILEDTK;
extern NSString *const DEFAULT_LOADEDTK;
extern int const ADVANCE_RECEIVED;
extern int const ADVANCE_ERROR;


@interface AdvanceSdkConfig : NSObject

+ (instancetype)shareInstance;

+ (NSString *)getSupplierIdWithTag:(NSString *)tag;

/// SDK配置
/// @param config 见 AdvanceSdkConfig.h
- (void)setConfig:(NSDictionary *)config;

/// 是否是Debug
@property(nonatomic) bool isDebug;

@end

NS_ASSUME_NONNULL_END
