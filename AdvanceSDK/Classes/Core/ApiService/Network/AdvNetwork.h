//
//  AdvNetwork.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/5/20.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger ,RequestMethod) {
    RequestMethod_GET = 0,
    RequestMethod_POST
};

typedef void(^AdvNetWorkSuccess)(id response);
typedef void(^AdvNetWorkFailure)(NSError *error);

@interface AdvNetwork : NSObject

/// 发送接口请求
/// - Parameters:
///   - urlString: 请求地址
///   - method: 请求方式
///   - parameters: 请求数据
///   - headers: 请求头
///   - timeout: 超时时间
///   - success: 成功回调
///   - failure: 失败回调
+ (void)sendRequestByUrlString:(NSString *)urlString
                        method:(RequestMethod)method
                    parameters:(nullable NSDictionary *)parameters
                       headers:(nullable NSDictionary *)headers
                       timeout:(NSTimeInterval)timeout
                       success:(AdvNetWorkSuccess)success
                       failure:(AdvNetWorkFailure)failure;

@end

NS_ASSUME_NONNULL_END
