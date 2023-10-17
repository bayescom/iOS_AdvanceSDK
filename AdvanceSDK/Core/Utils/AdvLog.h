//
//  AdvLog.h
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvSdkConfig.h"

#define ADVLog(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__]]

NS_ASSUME_NONNULL_BEGIN

@interface AdvLog : NSObject

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString;

@end

NS_ASSUME_NONNULL_END
