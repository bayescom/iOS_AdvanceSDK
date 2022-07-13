//
//  TXAdSDKInitializtion.h
//  TanxSDK-iOS
//
//  Created by guqiu on 2021/12/15.
//
//⚠️⚠️⚠️本类代码谨慎改动！必须CR

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


@interface TXAdSDKInitializtion : NSObject


/// 初始化SDK
/// @param appID 媒体申请的APPID
/// @param appKey 媒体获取的appKey
/// @return 初始化的结果
+ (BOOL)setupSDKWithAppID:(NSString *)appID andAppKey:(NSString *)appKey;



@end

NS_ASSUME_NONNULL_END
