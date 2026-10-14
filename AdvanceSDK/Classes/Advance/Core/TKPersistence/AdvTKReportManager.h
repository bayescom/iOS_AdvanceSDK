#import <Foundation/Foundation.h>
#import "AdvDefines.h"

NS_ASSUME_NONNULL_BEGIN

/// TK 的持久化、恢复和补发入口。每个 URL 是独立任务；事件参数必须已完成替换。
@interface AdvTKReportManager : NSObject
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
+ (instancetype)sharedInstance;
- (void)start;
- (void)enqueueURLs:(NSArray<NSString *> *)urls appId:(NSString *)appId eventType:(AdvSupplierReportTKEventType)eventType;
/// 检查到期任务，不绕过退避时间或 Retry-After。
- (void)flush;
@end

NS_ASSUME_NONNULL_END
