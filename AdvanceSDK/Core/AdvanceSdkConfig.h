//
//  AdvanceSdkConfig.h
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// MARK: ======================= SDK =======================
extern NSString *const AdvanceSdkAPIVersion;
extern NSString *const AdvanceSdkVersion;
extern NSString *const AdvanceSdkRequestUrl;
extern NSString *const AdvanceReportDataUrl;
extern NSString *const SDK_ID_MERCURY;
extern NSString *const SDK_ID_GDT;
extern NSString *const SDK_ID_CSJ;
extern NSString *const SDK_ID_BAIDU;
extern NSString *const DEFAULT_IMPTK;
extern NSString *const DEFAULT_CLICKTK;
extern NSString *const DEFAULT_SUCCEEDTK;
extern NSString *const DEFAULT_FAILEDTK;
extern NSString *const DEFAULT_LOADEDTK;
extern int const ADVANCE_RECEIVED;
extern int const ADVANCE_ERROR;


@interface AdvanceSdkConfig : NSObject
/// SDK版本
+ (NSString *)sdkVersion;

+ (instancetype)shareInstance;

/// 是否是Debug
@property(nonatomic) bool isDebug;

@end

NS_ASSUME_NONNULL_END
