//
//  AdvanceSDKManager.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/3.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSDKManager : NSObject

/// 初始化SDK
/// @param appId 应用的AppId
/// @param completion 初始化完成回调，error为空表示初始化成功
+ (void)startWithAppId:(NSString *)appId
            completion:(void (^)(NSError * _Nullable error))completion;

/// 获取SDK版本号
+ (NSString *)sdkVersion;

/// 是否打印日志，默认为YES
+ (void)openDebug:(BOOL)enable;

/// 是否允许个性化广告推送 默认为YES
+ (void)openAdTrack:(BOOL)enable;


@end

NS_ASSUME_NONNULL_END
