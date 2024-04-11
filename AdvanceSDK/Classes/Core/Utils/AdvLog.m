//
//  AdvLog.m
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "AdvLog.h"

@implementation AdvLog

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    
    if ([formatString containsString:@"[JSON]"]) {
        formatString = [formatString stringByReplacingOccurrencesOfString:@" " withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        formatString = [formatString stringByReplacingOccurrencesOfString:@"\t" withString:@""];
    }
    
    if ([AdvSdkConfig shareInstance].logEnable) {
#ifdef DEBUG
    NSLog(@"\n%s[line:%d][%@]", function, lineNumber, formatString);
#endif
    }
}

@end
