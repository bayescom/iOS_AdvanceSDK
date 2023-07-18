//
//  AdvLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "AdvLog.h"
#import <CommonCrypto/CommonDigest.h>

NSString *const LOG_LEVEL_NONE_SCHEME   = @"0";
NSString *const LOG_LEVEL_FATAL_SCHEME  = @"ADV_LEVE_FATAL";
NSString *const LOG_LEVEL_ERROR_SCHEME  = @"ADV_LEVEL_ERROR";
NSString *const LOG_LEVEL_WARING_SCHEME = @"ADV_LEVE_WARNING";
NSString *const LOG_LEVEL_INFO_SCHEME   = @"ADV_LEVE_INFO";
NSString *const LOG_LEVEL_DEBUG_SCHEME  = @"ADV_LEVE_DEBUG";


@implementation AdvLog

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    
}

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString level:(AdvLogLevel)level{
    
    
    NSString *scheme = @"";
    
    if (level == 1) {
        scheme = LOG_LEVEL_FATAL_SCHEME;
    } else if (level == 2) {
        
        scheme = LOG_LEVEL_ERROR_SCHEME;
    } else if (level == 3) {
        
        scheme = LOG_LEVEL_WARING_SCHEME;
    } else if (level == 4) {
        
        scheme = LOG_LEVEL_INFO_SCHEME;
    } else if (level == 5) {
        
        scheme = LOG_LEVEL_DEBUG_SCHEME;
    }
    
    if (level <= [AdvSdkConfig shareInstance].level) {
        [self customLogWithFunctionAction:function lineNumber:lineNumber formatString:formatString scheme:scheme];
    }
    
    
}

+ (void)customLogWithFunctionAction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString scheme:(NSString *)scheme {
    if ([formatString containsString:@"[JSON]"]) {
        formatString = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    NSLog(@"\n%s[line:%d][%@] %@", function, lineNumber, scheme, formatString);
    
}

@end
