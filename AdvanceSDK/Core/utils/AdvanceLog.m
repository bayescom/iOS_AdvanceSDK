//
// Created by allen on 2019-09-12.
// Copyright (c) 2019 AdvanceSDKDev. All rights reserved.
//

#import "AdvanceLog.h"
#import "AdvanceSdkConfig.h"

// 默认值为NO
static BOOL kLogEnable = NO;
@implementation AdvanceLog

+ (void)setLogEnable:(BOOL)enable {
    kLogEnable = enable;
}

+ (BOOL)getLogEnable {
    return kLogEnable;
}

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString {
    if ([self getLogEnable]) {// 开启了Log
        NSString *logMsg = [NSString stringWithFormat:@"%s[%d]\n[DEBUG] %@\n", function, lineNumber, formatString];
        NSLog(@"========================== [Bayes Log] ==============================\n%@\n", logMsg);
//        // store log
//        NSMutableArray *logArrM = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AdvanceLogKey"] mutableCopy];
//        [logArrM addObject:logMsg];
//        [[NSUserDefaults standardUserDefaults] setObject:[logArrM copy] forKey:@"AdvanceLogKey"];
//        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

@end
