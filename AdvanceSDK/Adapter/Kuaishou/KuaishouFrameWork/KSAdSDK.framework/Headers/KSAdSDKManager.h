//
//  KSAdSDKManager.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/8/28.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KSAdSDKError.h"

typedef NS_ENUM(NSInteger, KSAdSDKLogLevel) {
    KSAdSDKLogLevelAll      =       0,
    KSAdSDKLogLevelVerbose,  // 此类别的日记不会记录到日志文件中
    KSAdSDKLogLevelDebug,
    KSAdSDKLogLevelVerify,
    KSAdSDKLogLevelInfo,
    KSAdSDKLogLevelWarn,
    KSAdSDKLogLevelError,
    KSAdSDKLogLevelOff,
};

NS_ASSUME_NONNULL_BEGIN

@class KSAdUserInfo;


@interface KSAdSDKManager : NSObject

/// SDK 版本号
@property (nonatomic, readonly, class) NSString *SDKVersion;

/// Auto play video on Non Wi-Fi environment or not, default is NO
@property (nonatomic, assign, class) BOOL dataFlowAutoStart;

/**
 * @brief start ad sdk
 * @param appId             ad app id
 */
+ (void)setAppId:(NSString *)appId;
// optional
+ (void)setAppName:(NSString *)appName;
// optional
+ (void)setUserInfoBlock:(void(^)(KSAdUserInfo *))userInfoBlock;
// optional
+ (void)setAppTag:(NSString *)appTag;
// optional, enable personalized recommendation, default is YES
+ (void)setEnablePersonalRecommend:(BOOL)enable;
/**
 Configure development mode.
 @param level : default BUAdSDKLogLevelNone
 */
// optional
+ (void)setLoglevel:(KSAdSDKLogLevel)level;

+ (void)setAutoHideUIRemoteKeyboardWindow:(BOOL)autoHideUIRemoteKeyboardWindow;

+ (NSString *)appId;

+ (NSString *)deviceId; //获取did

@end

NS_ASSUME_NONNULL_END
