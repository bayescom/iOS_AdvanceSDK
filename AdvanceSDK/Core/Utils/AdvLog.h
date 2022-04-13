//
//  AdvLog.h
//  Example
//
//  Created by CherryKing on 2019/11/5.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AdvSdkConfig.h"

@class AdvLog;



#define ADV_LEVEL_FATAL_LOG(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:AdvLogLevel_Fatal]

#define ADV_LEVEL_ERROR_LOG(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:AdvLogLevel_Error]

#define ADV_LEVEL_WARING_LOG(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:AdvLogLevel_Warning]

#define ADV_LEVEL_INFO_LOG(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:AdvLogLevel_Info]

#define ADV_LEVEL_DEBUG_LOG(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__] level:AdvLogLevel_Debug]


#define ADVLog(format,...)  [AdvLog customLogWithFunction:__FUNCTION__ lineNumber:__LINE__ formatString:[NSString stringWithFormat:format, ##__VA_ARGS__]]
#define ADVLogJSONData(data)  [AdvLog logJsonData:data]

NS_ASSUME_NONNULL_BEGIN


@interface AdvLog : NSObject

// 日志输出方法
+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString level:(AdvLogLevel)level;

+ (void)customLogWithFunction:(const char *)function lineNumber:(int)lineNumber formatString:(NSString *)formatString;

// 记录data类型数据
+ (void)logJsonData:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
