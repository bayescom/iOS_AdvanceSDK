//
//  MercuryConfigManager.h
//  BayesSDK
//
//  Created by CherryKing on 2019/11/4.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MercuryConfigManager : NSObject

/// 设置AppID
/// @param appID 应用的AppID
/// @param mediaKey 媒体Key
+ (void)setAppID:(NSString *)appID mediaKey:(NSString *)mediaKey;

/// 选择是否开启日志打印
/// @param isDebug 是否打印日志
+ (void)openDebug:(BOOL)isDebug;

/// 获取 SDK 版本
+ (NSString *)sdkVersion;

@end

NS_ASSUME_NONNULL_END
