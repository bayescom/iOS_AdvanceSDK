//
//  AdvNetwork.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/5/20.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import "AdvNetwork.h"
#import "AdvAFNetworking.h"
#import "AdvGZipRequestSerializer.h"

@implementation AdvNetwork

+ (AdvAFHTTPSessionManager *)AFSessionManager {
    static AdvAFHTTPSessionManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [AdvAFHTTPSessionManager manager];
        _manager.responseSerializer = [AdvAFHTTPResponseSerializer serializer];
        _manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html", @"application/json", @"text/json", @"text/plain", nil];
    });
    return _manager;
}

+ (void)sendRequestByUrlString:(NSString *)urlString
                        method:(RequestMethod)method
                    parameters:(NSDictionary *)parameters
                       headers:(NSDictionary *)headers
                       timeout:(NSTimeInterval)timeout
                       success:(AdvNetWorkSuccess)success
                       failure:(AdvNetWorkFailure)failure {

    AdvAFHTTPSessionManager *manager = [AdvNetwork AFSessionManager];

    // 每个请求使用独立的Serializer，避免并发请求互相覆盖编码方式和timeout。
    // SessionManager仍然复用，其内部NSURLSession继续负责并发执行网络任务。
    AdvAFHTTPRequestSerializer *requestSerializer = nil;
    NSString *HTTPMethod = nil;
    switch (method) {
        case RequestMethod_POST: // httpbody要求json gzip压缩
            requestSerializer = [AdvGZipRequestSerializer serializer];
            HTTPMethod = @"POST";
            break;
        case RequestMethod_GET:
            requestSerializer = [AdvAFHTTPRequestSerializer serializer];
            HTTPMethod = @"GET";
            break;
    }
    requestSerializer.timeoutInterval = timeout;

    // 在局部Serializer上完成参数编码和GZip，不再修改共享manager.requestSerializer。
    NSError *serializationError = nil;
    NSString *absoluteURLString = [[NSURL URLWithString:urlString relativeToURL:manager.baseURL] absoluteString];
    NSMutableURLRequest *request = [requestSerializer requestWithMethod:HTTPMethod
                                                              URLString:absoluteURLString
                                                             parameters:parameters
                                                                  error:&serializationError];

    for (NSString *headerField in headers.keyEnumerator) {
        [request addValue:headers[headerField] forHTTPHeaderField:headerField];
    }

    if (!request || serializationError) {
        NSError *requestError = serializationError ?: [NSError errorWithDomain:NSURLErrorDomain
                                                                           code:NSURLErrorBadURL
                                                                       userInfo:@{
            NSLocalizedDescriptionKey: @"Failed to serialize request."
        }];
        if (failure) {
            dispatch_async(manager.completionQueue ?: dispatch_get_main_queue(), ^{
                failure(requestError);
            });
        }
        return;
    }

    // 完整Request已经与其他请求隔离，交给共享SessionManager并发执行即可。
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [manager dataTaskWithRequest:request
                            uploadProgress:nil
                          downloadProgress:nil
                         completionHandler:^(__unused NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (failure) {
                failure(error);
            }
        } else if (success) {
            success(responseObject);
        }
    }];
    [dataTask resume];
}

@end
