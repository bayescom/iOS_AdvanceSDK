//
//  AdvParameterHandler.h
//  MercurySDK
//
//  Created by guangyao on 2024/5/20.
//  Copyright © 2024 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvParameterHandler : NSObject

// 广告请求参数
+ (NSDictionary *)requestParameterWithSpotId:(NSString *)adspotId
                                       reqId:(NSString *)reqId
                                       extra:(NSDictionary *)extra;

// tk上报拼接参数
+ (NSString *)joinParamtersWithUrl:(NSString *)urlString
                         eventType:(AdvSupplierReportTKEventType)eventType
                             price:(NSInteger)price
                     loadTimestamp:(NSTimeInterval)loadTimestamp
                       cachedReqId:(nullable NSString *)cachedReqId
                             error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
