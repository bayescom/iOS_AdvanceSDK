#import <Foundation/Foundation.h>
#import "AdvDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// 一个已完成参数替换的 TK URL。重试不会重新生成 URL 或事件时间。
@interface AdvTKEvent : NSObject <NSCopying>
@property (nonatomic, copy) NSString *taskId;
@property (nonatomic, copy) NSString *appId;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, assign) AdvSupplierReportTKEventType eventType;
@property (nonatomic, assign) NSTimeInterval createdAt;
@property (nonatomic, assign) NSTimeInterval expiresAt;
@property (nonatomic, assign) NSTimeInterval nextRetryAt;
/// 已开始的请求次数，包含首次发送；请求前落盘，重启后继续计数。
@property (nonatomic, assign) NSUInteger attemptCount;

+ (BOOL)isValidURLString:(NSString *)url;
+ (nullable instancetype)eventWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;
@end

NS_ASSUME_NONNULL_END
