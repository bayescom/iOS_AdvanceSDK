//
//  AdvApiService.h
//  MercurySDK
//
//  Created by guangyao on 2025/11/21.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvApiService : NSObject

/// 加载策略信息
+ (void)loadPolicyDataWithParameters:(NSDictionary *)parameters
                          completion:(void(^)(AdvPolicyModel *model, NSError *error))completion;

/// TK监测数据上报
+ (void)reportAdDataWithEventType:(AdvSupplierReportTKEventType)eventType
                         supplier:(AdvSupplier *)supplier
                    loadTimestamp:(NSTimeInterval)loadTimestamp
                            error:(nullable NSError *)error;


/// 验证服务端激励回调
+ (void)verifyServerSideRewardedURL:(NSString *)URLString
                         parameters:(nullable NSDictionary *)parameters
                         completion:(void(^)(NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
