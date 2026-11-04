//
//  AdvNetwork.h
//  AdvanceSDK
//
//  Created by guangyao on 2024/5/20.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvImageUploadResult.h"

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

/// 上传图片到素材服务。文件名须带扩展名；支持 jpg、jpeg、png、gif、webp、bmp。
/// 单次 1～9 张，单张不超过 5 MB，完整 multipart 请求不超过 20 MB。
/// 成功回调返回原始 JSON 数据，调用方需处理 SUCCESS、PARTIAL_SUCCESS 和 ALL_FAILED。
+ (void)uploadImageFiles:(NSArray<AdvNetworkImageFile *> *)imageFiles
                 timeout:(NSTimeInterval)timeout
                 success:(AdvNetWorkSuccess)success
                 failure:(AdvNetWorkFailure)failure;

@end

NS_ASSUME_NONNULL_END
