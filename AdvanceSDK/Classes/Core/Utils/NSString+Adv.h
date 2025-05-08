//
//  NSString+Adv.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/5/6.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (Adv)

+ (NSString *)adv_validString:(NSString *)str;

/// JSON字符串转化为字典
/// @param jsonString Json字符串
+ (NSDictionary *)adv_dictionaryWithJsonString:(NSString *)jsonString;

/// 字典转json字符串方法
/// @param dict 字典
+ (NSString *)adv_jsonStringWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
