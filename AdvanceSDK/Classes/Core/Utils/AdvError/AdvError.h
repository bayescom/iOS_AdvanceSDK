//
//  AdvError.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>
#import "AdvDefines.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvError : NSObject

+ (instancetype)errorWithCode:(AdvErrorCode)code;

/// @param code 错误码
/// @param message 当 code 不在本地错误表中，则自定义错误信息
+ (instancetype)errorWithCode:(NSInteger)code
                      message:(NSString *)message;

- (NSError *)toNSError;

@end

NS_ASSUME_NONNULL_END
