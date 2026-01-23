//
//  AdvanceSDKManager.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSDKManager : NSObject

/// 设置AppID
/// @param appId 应用的AppId
+ (void)setAppId:(NSString *)appId;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

/// 选择是否开启日志打印
/// @param enable 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 是否允许个性化广告推送 默认为允许
+ (void)openAdTrack:(BOOL)open;


@end

NS_ASSUME_NONNULL_END
