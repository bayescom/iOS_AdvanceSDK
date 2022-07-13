//
//  TXAdSDKConfiguration.h
//  TanxSDK-iOS
//
//  Created by guqiu on 2021/12/15.
//

#import <Foundation/Foundation.h>
#import <TanxSDK/TXAdEnum.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdSDKConfiguration : NSObject

/// 当前的APPID(只读)
@property (nonatomic, copy, readonly) NSString *appID;
@property (nonatomic, copy, readonly) NSString *appKey;
/// 开发阶段调试相关的配置(只读)
@property (nonatomic, assign, readonly) TXAdSDKLogLevel logLevel;

/// 当前是否禁止获取idfa(只读)
@property (nonatomic, assign, readonly) BOOL forbiddenUseIDFA;

/// 单例初始化
+ (instancetype)sharedConfiguration;

/// 获取SDK版本号
+ (NSString *)sdkVersion;

/// 获取SDK构建号
+ (double)sdkBuildNumber;

/// 获取SDK idfv
+ (NSString *)idfv;

/// 是否禁止SDK获取idfa
/// @param forbiddened YES:禁止获取
- (void)forbiddenUseIDFA:(BOOL)forbiddened;

/// 禁止SDK获取idfa前提下，外部媒体通过该接口传递IDFA
/// @param idfa 外部传入的idfa
- (void)setSDKIDFA:(NSString *)idfa;

/// 外部媒体通过该接口传递经纬度
/// @param lon 经度
/// @param lat 纬度
- (void)setSDKLBSLon:(NSString *)lon lat:(NSString *)lat;

/// 关闭个性化推荐控制
/// @param closed YES:禁止获取
- (void)closePersonalized:(BOOL)closed;

/// 设置开发阶段调试相关配置
/// @param debugSetting debugLevel
- (void)setDebugSetting:(TXAdSDKLogLevel *)debugSetting;


@end

NS_ASSUME_NONNULL_END
