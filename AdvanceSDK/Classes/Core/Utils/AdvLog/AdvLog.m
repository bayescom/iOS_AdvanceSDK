//
//  AdvLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "AdvLog.h"

// 默认值为YES
static BOOL kLogEnable = YES;

@implementation AdvLog

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    
    if ([formatString containsString:@"[JSON]"]) {
        formatString = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    
    if ([self getLogEnable]) {
        NSLog(@"🚀Advance Console:🚀 \n%s[line:%d][%@]", function, lineNumber, formatString);
    }
}

@end
