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

static NSString *const kAdvImageUploadURL = @"https://cruiser.bayescom.cn/upload_images";
static NSString *const kAdvImageUploadErrorDomain = @"com.bayescom.AdvanceSDK.imageUpload";
static const NSUInteger kAdvImageUploadMaxFileBytes = 5 * 1024 * 1024;
static const NSUInteger kAdvImageUploadMaxRequestBytes = 20 * 1024 * 1024;

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



+ (void)uploadImageFiles:(NSArray<AdvNetworkImageFile *> *)imageFiles
                 timeout:(NSTimeInterval)timeout
                 success:(AdvNetWorkSuccess)success
                 failure:(AdvNetWorkFailure)failure {
    if (imageFiles.count == 0 || imageFiles.count > 9) {
        [self uploadFailureWithCode:1 description:@"单次上传图片数量须为 1～9 张。" failure:failure];
        return;
    }

    NSUInteger totalFileBytes = 0;
    NSMutableArray<NSString *> *mimeTypes = [NSMutableArray arrayWithCapacity:imageFiles.count];
    NSCharacterSet *invalidFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\"\\\r\n"];
    for (AdvNetworkImageFile *imageFile in imageFiles) {
        if (![imageFile isKindOfClass:AdvNetworkImageFile.class] ||
            imageFile.data.length == 0 ||
            imageFile.fileName.length == 0 ||
            ![imageFile.fileName isEqualToString:imageFile.fileName.lastPathComponent] ||
            [imageFile.fileName rangeOfCharacterFromSet:invalidFileNameCharacters].location != NSNotFound) {
            [self uploadFailureWithCode:2 description:@"图片数据或文件名无效。" failure:failure];
            return;
        }
        NSString *mimeType = [self mimeTypeForImageFileName:imageFile.fileName];
        if (!mimeType) {
            [self uploadFailureWithCode:2 description:@"不支持该图片文件格式。" failure:failure];
            return;
        }
        if (imageFile.data.length > kAdvImageUploadMaxFileBytes) {
            [self uploadFailureWithCode:3 description:@"单张图片不得超过 5 MB。" failure:failure];
            return;
        }
        if (totalFileBytes > kAdvImageUploadMaxRequestBytes - imageFile.data.length) {
            [self uploadFailureWithCode:3 description:@"上传图片总大小不得超过 20 MB。" failure:failure];
            return;
        }
        totalFileBytes += imageFile.data.length;
        [mimeTypes addObject:mimeType];
    }

    // 使用独立的普通 Serializer 构造 multipart，避免现有 POST 的 GZip JSON 编码。
    AdvAFHTTPRequestSerializer *serializer = [AdvAFHTTPRequestSerializer serializer];
    serializer.timeoutInterval = timeout > 0 ? timeout : 15.0;
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [serializer multipartFormRequestWithMethod:@"POST"
                                                                   URLString:kAdvImageUploadURL
                                                                  parameters:nil
                                                   constructingBodyWithBlock:^(id<AdvAFMultipartFormData> formData) {
        [imageFiles enumerateObjectsUsingBlock:^(AdvNetworkImageFile *imageFile, NSUInteger index, BOOL *stop) {
            [formData appendPartWithFileData:imageFile.data
                                       name:@"images"
                                   fileName:imageFile.fileName
                                   mimeType:mimeTypes[index]];
        }];
    } error:&serializationError];
    if (!request || serializationError) {
        NSError *error = serializationError ?: [NSError errorWithDomain:NSURLErrorDomain
                                                                   code:NSURLErrorBadURL
                                                               userInfo:@{NSLocalizedDescriptionKey: @"图片上传请求构造失败。"}];
        [self uploadFailureWithError:error failure:failure];
        return;
    }

    // Content-Length 包含 multipart 边界和文件头，按完整请求大小校验。
    long long requestBytes = [[request valueForHTTPHeaderField:@"Content-Length"] longLongValue];
    if (requestBytes <= 0 || requestBytes > kAdvImageUploadMaxRequestBytes) {
        [self uploadFailureWithCode:3 description:@"完整上传请求不得超过 20 MB。" failure:failure];
        return;
    }

    AdvAFHTTPSessionManager *manager = [self AFSessionManager];
    NSURLSessionUploadTask *task = [manager uploadTaskWithStreamedRequest:request
                                                                 progress:nil
                                                        completionHandler:^(__unused NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if (failure) failure(error);
        } else if (success) {
            success(responseObject);
        }
    }];
    if (!task) {
        [self uploadFailureWithCode:4 description:@"图片上传任务创建失败。" failure:failure];
        return;
    }
    [task resume];
}

+ (NSString *)mimeTypeForImageFileName:(NSString *)fileName {
    static NSDictionary<NSString *, NSString *> *mimeTypes;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mimeTypes = @{
            @"jpg": @"image/jpeg", @"jpeg": @"image/jpeg", @"png": @"image/png",
            @"gif": @"image/gif", @"webp": @"image/webp", @"bmp": @"image/bmp"
        };
    });
    return mimeTypes[fileName.pathExtension.lowercaseString];
}

+ (void)uploadFailureWithError:(NSError *)error failure:(AdvNetWorkFailure)failure {
    if (!failure) {
        return;
    }
    dispatch_async([self AFSessionManager].completionQueue ?: dispatch_get_main_queue(), ^{
        failure(error);
    });
}

+ (void)uploadFailureWithCode:(NSInteger)code description:(NSString *)description failure:(AdvNetWorkFailure)failure {
    NSError *error = [NSError errorWithDomain:kAdvImageUploadErrorDomain
                                         code:code
                                     userInfo:@{NSLocalizedDescriptionKey: description}];
    [self uploadFailureWithError:error failure:failure];
}

@end
