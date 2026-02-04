//
//  AdvApiService.m
//  MercurySDK
//
//  Created by guangyao on 2025/11/21.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import "AdvApiService.h"
#import "AdvNetwork.h"
#import "AdvReachability.h"
#import "AdvError.h"
#import "AdvConstantHeader.h"
#import "AdvParameterHandler.h"

@implementation AdvApiService

//+ (NSString*)genAdRequestLink:(NSString *)command {
//    NSString *url = [NSString stringWithFormat:@"%@%@", AdvanceSDKRequestUrl, command];
//    return url;
//}

+ (void)loadPolicyDataWithParameters:(NSDictionary *)parameters completion:(void (^)(AdvPolicyModel *model, NSError *error))completion {
    
    if (![AdvDeviceManager sharedInstance].appId.length) { //SDK配置校验
        return completion(nil, [AdvError errorWithCode:AdvErrorCode_SDKInitException].toNSError);
    }
    AdvReachability *reach = [AdvReachability reachabilityForInternetConnection];
    if (reach.currentReachabilityStatus == AdvNetworkStatusNotReachable) {  //网络不可用检测
        return completion(nil, [AdvError errorWithCode:AdvErrorCode_NoNetwork].toNSError);
    }
    
    [AdvNetwork sendRequestByUrlString:AdvanceSDKRequestUrl method:RequestMethod_POST parameters:parameters headers:nil timeout:5.f success:^(id  _Nonnull response) {
        
        if (![response isKindOfClass:[NSData class]]) {
            return completion(nil, [AdvError errorWithCode:AdvErrorCode_ResponseTypeError].toNSError);
        }
        [self handleResponseObject:response completion:completion];
        
    } failure:^(NSError * _Nonnull error) {
        NSError *reason = nil;
        if (error.code == -1001) { // 请求超时
            reason = [AdvError errorWithCode:AdvErrorCode_Timeout].toNSError;
        } else {
            reason = [AdvError errorWithCode:AdvErrorCode_NetworkError message:error.userInfo[NSLocalizedDescriptionKey]].toNSError;
        }
        completion(nil, reason);
    }];
}

// 处理返回正确的策略对象
+ (void)handleResponseObject:(NSData *)dataObject completion:(void(^)(AdvPolicyModel *model, NSError *error))completion {
    AdvPolicyModel *model = [AdvPolicyModel adv_modelWithJSON:dataObject];
    // Parse Error
    if (!model) {
        return completion(nil, [AdvError errorWithCode:AdvErrorCode_ParseModelError].toNSError);
    }
    // Code not 200
    if (model.code != 200) {
        return completion(nil, [AdvError errorWithCode:AdvErrorCode_Not200].toNSError);
    }
    // No suppliers
    if (!model.suppliers.count) {
        return completion(nil, [AdvError errorWithCode:AdvErrorCode_NoneSupplier].toNSError);
    }
    completion(model, nil);
}

+ (void)reportAdDataWithEventType:(AdvSupplierReportTKEventType)eventType
                         supplier:(AdvSupplier *)supplier
                    loadTimestamp:(NSTimeInterval)loadTimestamp
                            error:(nullable NSError *)error {
    NSArray<NSString *> *reportUrls = nil;
    /// 按照类型判断上报地址
    if (eventType == AdvSupplierReportTKEventLoaded) { // 启动SDK上报
        reportUrls = supplier.loadedtk;
    } else if (eventType == AdvSupplierReportTKEventLoadEnd) { // 渠道SDK初始化成功上报
        reportUrls = supplier.loadendtk;
    } else if (eventType == AdvSupplierReportTKEventSucceed) { // 获取广告成功上报
        reportUrls = supplier.succeedtk;
    } else if (eventType == AdvSupplierReportTKEventFailed) { // 获取广告失败上报
        reportUrls = supplier.failedtk;
    } else if (eventType == AdvSupplierReportTKEventExposed) { // 广告曝光成功上报
        reportUrls = supplier.imptk;
    } else if (eventType == AdvSupplierReportTKEventClicked) { // 点击上报
        reportUrls = supplier.clicktk;
    } else if (eventType == AdvSupplierReportTKEventBidWin) { // 广告竞胜上报
        reportUrls = supplier.wintk;
    }
    
    if (reportUrls.count == 0) {return;}
    
    [reportUrls enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *reportUrl = [AdvParameterHandler joinParamtersWithUrl:obj eventType:eventType price:supplier.sdk_price loadTimestamp:loadTimestamp cachedReqId:supplier.cachedReqId error:error];
        
        [AdvNetwork sendRequestByUrlString:reportUrl method:RequestMethod_GET parameters:nil headers:nil timeout:5.f success:^(id  _Nonnull response) {
            NSString *result = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
            AdvLog(@"AdvTK上报成功：%@-%@", result, reportUrl);
        } failure:^(NSError * _Nonnull error) {
            AdvLog(@"AdvTK上报失败：%@-%@", error, reportUrl);
        }];
    }];
    
}

+ (void)verifyServerSideRewardedURL:(NSString *)URLString
                         parameters:(nullable NSDictionary *)parameters
                         completion:(void(^)(NSError *error))completion {
    
    [AdvNetwork sendRequestByUrlString:URLString method:RequestMethod_POST parameters:parameters headers:nil timeout:3.f success:^(id  _Nonnull response) {
        if(![response isKindOfClass:[NSData class]]) {
            return completion([AdvError errorWithCode:AdvErrorCode_ResponseTypeError].toNSError);
        }
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:nil];
        if ([dict[@"code"] intValue] == 1) { // 成功
            completion(nil);
        } else { // 失败
            completion([AdvError errorWithCode:[dict[@"code"] intValue] message:dict[@"msg"]].toNSError);
        }
    } failure:^(NSError * _Nonnull error) {
        completion(error);
    }];
}

@end
