//
//  AdvAdsportInfoUtil.h
//  AdvanceSDK
//
//  Created by MS on 2021/3/15.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvAdsportInfoUtil : NSObject
// 校验是否支持并行(此为最高优先级)
+ (BOOL)isSupportParallelWithAdTypeName:(NSString *)adTypeName supplierId:(NSString *)ID;
@end

NS_ASSUME_NONNULL_END
