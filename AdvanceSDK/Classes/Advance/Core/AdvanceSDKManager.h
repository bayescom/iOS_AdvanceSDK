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

/// 获取SDK版本号
+ (NSString *)sdkVersion;

/// 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 是否允许个性化广告推送 默认为YES
+ (void)openAdTrack:(BOOL)enable;


@end

NS_ASSUME_NONNULL_END
