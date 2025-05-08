//
//  AdvError.h
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 策略相关
typedef NS_ENUM(NSUInteger, AdvErrorCode) {
    AdvErrorCode_101    =    101,
    AdvErrorCode_102    =    102,
    AdvErrorCode_103    =    103,
    AdvErrorCode_104    =    104,
    AdvErrorCode_105    =    105,
    AdvErrorCode_106    =    106,
};

@interface AdvError : NSObject

+ (instancetype)errorWithCode:(AdvErrorCode)code;

/// @param code 错误码
/// @param message 当 code 不在本地错误表中，则自定义错误信息
+ (instancetype)errorWithCode:(NSInteger)code
                      message:(NSString *)message;

- (NSError *)toNSError;

@end

NS_ASSUME_NONNULL_END
