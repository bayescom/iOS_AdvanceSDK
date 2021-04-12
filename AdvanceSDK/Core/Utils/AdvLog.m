//
//  AdvLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "AdvLog.h"
#import "AdvSdkConfig.h"
#import <CommonCrypto/CommonDigest.h>

@interface NSString (MD5)

- (NSString *)md5;

@end

@implementation NSString (MD5)

- (NSString *)md5 {
    const char* character = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(character, strlen(character), result);
    NSMutableString *md5String = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        [md5String appendFormat:@"%02x",result[i]];
    }
    return md5String;
}

@end

@implementation AdvLog

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([AdvSdkConfig shareInstance].isDebug) {
        if ([formatString containsString:@"[JSON]"]) {
            formatString = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
            formatString = [formatString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
            formatString = [formatString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
        }
        NSLog(@"\n%s[line:%d][ADV_DEBUG] %@", function, lineNumber, formatString);
    }
}

+ (void)logJsonData:(NSData *)data {
    NSDictionary *res = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSString *md5 = [[res description] md5];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:md5];
    
//    ADVLog(@"[JSON][-%@-]", md5);
    ADVLog(@"%@", res);
}

@end
