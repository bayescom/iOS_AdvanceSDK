//
//  AdvParameterHandler.m
//  MercurySDK
//
//  Created by guangyao on 2024/5/20.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import "AdvParameterHandler.h"
#import "AdvConstantHeader.h"

@implementation AdvParameterHandler

+ (NSDictionary *)requestParameterWithSpotId:(NSString *)adspotId
                                       reqId:(NSString *)reqId
                                       extra:(NSDictionary *)extra {
    
    NSDictionary *deviceDict = [[AdvDeviceManager sharedInstance] getDeviceInfoForAdRequest];
    NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithDictionary:deviceDict];
    
    [parameters adv_safeSetObject:adspotId forKey:@"adspotid"];
    [parameters adv_safeSetObject:reqId forKey:@"reqid"];
    [parameters adv_safeSetObject:extra forKey:@"ext"];
    
    return parameters;
}

+ (NSString *)joinParamtersWithUrl:(NSString *)urlString
                         eventType:(AdvSupplierReportTKEventType)eventType
                             price:(NSInteger)price
                     loadTimestamp:(NSTimeInterval)loadTimestamp
                       cachedReqId:(nullable NSString *)cachedReqId
                             error:(nullable NSError *)error {
    /// replace timestamp
    NSTimeInterval currentTimeStamp = [[NSDate date] timeIntervalSince1970] * 1000;
    urlString = [urlString stringByReplacingOccurrencesOfString:@"__TIME__" withString:[NSString stringWithFormat:@"%0.f", currentTimeStamp]];
    /// append is_cahced & cached_reqid
    if (cachedReqId) {
        urlString = [NSString stringWithFormat:@"%@&is_cahced=1&cached_reqid=%@", urlString, cachedReqId];
    }
    
    NSTimeInterval costTime = currentTimeStamp - loadTimestamp;
    
    switch (eventType) {
        case AdvSupplierReportTKEventLoaded:
        case AdvSupplierReportTKEventLoadEnd:
            // 拼接SDK启动耗时
            urlString = [NSString stringWithFormat:@"%@&t_msg=l_%.0f", urlString, costTime];
            break;
        case AdvSupplierReportTKEventSucceed: {
            // 拼接竞价
            if (price) {
                urlString = [NSString stringWithFormat:@"%@&bidResult=%ld", urlString, (long)price];
            }
            break;
        }
        case AdvSupplierReportTKEventExposed:
        case AdvSupplierReportTKEventBidWin: {
            // 拼接广告曝光/竞价成功耗时
            urlString = [NSString stringWithFormat:@"%@&t_msg=tt_%.0f", urlString, costTime];
            // 拼接竞价
            if (price > 0) {
                urlString = [NSString stringWithFormat:@"%@&bidResult=%ld", urlString, (long)price];
            }
            break;
        }
        case AdvSupplierReportTKEventFailed: {
            // 拼接错误码
            if (error) {
                urlString = [NSString stringWithFormat:@"%@&t_msg=err_%ld", urlString, (long)error.code];
            }
        }
            break;
        default:
            break;
    }
    
    return urlString;
}

@end
