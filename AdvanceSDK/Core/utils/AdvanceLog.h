//
// Created by allen on 2019-09-12.
// Copyright (c) 2019 AdvanceSDKDev. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AdvanceLog;

#define AdvanceLog(format,...)  [AdvanceLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__]]

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceLog : NSObject

// 设置日志输出状态
+ (void)setLogEnable:(BOOL)enable;

// 获取日志输出状态
+ (BOOL)getLogEnable;

// 日志输出方法
+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString;

@end

NS_ASSUME_NONNULL_END
