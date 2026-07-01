//
//  NSDictionary+adv.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/17.
//

#import "NSDictionary+adv.h"

@implementation NSDictionary (adv)

// 转为可读的多行字符串
- (NSString *)toErrorDescriptionString {
    if (self.count == 0) {
        return @"(no errors)";
    }
    
    NSMutableString *result = [NSMutableString stringWithString:@"Errors:\n"];
    [self enumerateKeysAndObjectsUsingBlock:^(id key, NSError *error, BOOL *stop) {
        [result appendFormat:@"  • %@: %@ (code=%ld, domain=%@)\n",
         key,
         [error localizedDescription] ?: @"Unknown error",
         (long)error.code,
         error.domain ?: @"unknown"];
    }];
    return [result copy];
}

// 转为单行简洁字符串（用于日志）
- (NSString *)toErrorLogString {
    if (self.count == 0) {
        return @"no_errors";
    }
    
    NSMutableArray *items = [NSMutableArray array];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSError *error, BOOL *stop) {
        [items addObject:[NSString stringWithFormat:@"%@:%ld", key, (long)error.code]];
    }];
    return [items componentsJoinedByString:@", "];
}

// 转为 JSON（用于上报）
- (NSString *)toErrorJSONString {
    if (self.count == 0) {
        return @"{}";
    }
    
    NSMutableDictionary *serializableDict = [NSMutableDictionary dictionary];
    [self enumerateKeysAndObjectsUsingBlock:^(NSString *key, NSError *error, BOOL *stop) {
        serializableDict[key] = @{
            @"code": @(error.code),
            @"domain": error.domain ?: @"",
            @"message": [error localizedDescription] ?: @""
        };
    }];
    
    NSError *jsonError;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:serializableDict
                                                       options:0
                                                         error:&jsonError];
    if (jsonError || !jsonData) {
        return [self description];
    }
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}


@end
