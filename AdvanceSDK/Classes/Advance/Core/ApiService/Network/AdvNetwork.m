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
    switch (method) {
        case RequestMethod_POST: // httpbody要求json gzip压缩
            manager.requestSerializer = [AdvGZipRequestSerializer serializer];
            break;
        case RequestMethod_GET:
            manager.requestSerializer = [AdvAFHTTPRequestSerializer serializer];
            break;
    }
    manager.requestSerializer.timeoutInterval = timeout;
    
    // Callback
    void (^AdvHTTPRequestSuccess)(NSURLSessionDataTask *task, id responseObject) = ^void(NSURLSessionDataTask *task, id responseObject) {
        success ? success(responseObject) : nil;
    };
    
    void (^AdvHTTPRequestFailure)(NSURLSessionDataTask *task, NSError *error) = ^void(NSURLSessionDataTask *task, NSError *error){
        failure ? failure(error) : nil;
    };
    
    switch (method) {
        case RequestMethod_GET:
            [manager GET:urlString parameters:parameters headers:headers progress:nil success:AdvHTTPRequestSuccess failure:AdvHTTPRequestFailure];
            break;
        case RequestMethod_POST:
            [manager POST:urlString parameters:parameters headers:headers progress:nil success:AdvHTTPRequestSuccess failure:AdvHTTPRequestFailure];
            break;
    }
    
}

@end
