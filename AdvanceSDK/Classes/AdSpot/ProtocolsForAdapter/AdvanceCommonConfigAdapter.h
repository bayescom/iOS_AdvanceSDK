//
//  AdvanceCommonConfigAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/1.
//

#import <Foundation/Foundation.h>

/// 广告adapter的基本配置协议
@protocol AdvanceCommonConfigAdapter <NSObject>

/// adn初始化方法
+ (void)initializeAdapterWithAppId:(NSString *)appId
                            appKey:(NSString *)appkey
                        completion:(void (^)(NSError *error))completion;

/// adn的版本号
+ (NSString *)sdkVersion;

/// adapter的版本号
//+ (NSString *)adapterVersion;

@end

