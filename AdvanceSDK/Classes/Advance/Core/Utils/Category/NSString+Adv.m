//
//  NSString+Adv.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/5/6.
//

#import "NSString+Adv.h"

@implementation NSString (Adv)
+ (NSString *)adv_validString:(NSString *)str {
    return str ? str : @"";
}

+ (BOOL)adv_isEmptyString:(NSString *)aStr {
    if (!aStr) {
        return YES;
    }
    if ([aStr isKindOfClass:[NSNull class]]) {
        return YES;
    }
    if (!aStr.length) {
        return YES;
    }
    NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmedStr = [aStr stringByTrimmingCharactersInSet:set];
    if (!trimmedStr.length) {
        return YES;
    }
    return NO;
}

#pragma mark - 字典转json字符串方法
+ (NSString *)adv_jsonStringWithDictionary:(NSDictionary *)dict {
    // 1. 安全校验：入参为空或非合法 JSON 对象时直接返回 nil
    if (!dict || ![NSJSONSerialization isValidJSONObject:dict]) {
        return nil;
    }
    
    NSError *error = nil;
    // 2. options 传入 0：直接生成无换行、无额外空格的紧凑型 JSON 数据
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    
    if (!jsonData || error) {
        return nil;
    }
    
    // 3. 直接转为 NSString 返回，避免创建 NSMutableString 及字符串替换的性能开销
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

#pragma mark -JSON字符串转化为字典
+ (NSDictionary *)adv_dictionaryWithJsonString:(NSString *)jsonString {
    if (jsonString == nil) {
        return nil;
    }
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        return nil;
    }
    return dic;
}

@end
