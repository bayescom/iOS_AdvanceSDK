#import <Foundation/Foundation.h>
@class AdvTKEvent;

NS_ASSUME_NONNULL_BEGIN

/// 仅由 TK 调度串行队列访问；同一路径只创建一个实例。
/// path 必须为 TK 独占目录；启动恢复时确认数据库损坏会删除此目录并重建。
/// 每个任务存为一行；成功恢复后才能保存或删除任务。
@interface AdvTKEventStore : NSObject
- (instancetype)initWithPath:(NSString *)path;
/// 供调度器启动恢复使用；运行中的保存和删除失败不会触发重建。
- (nullable NSArray<AdvTKEvent *> *)loadEventsWithError:(NSError * _Nullable * _Nullable)error;
- (BOOL)saveEvent:(AdvTKEvent *)event error:(NSError * _Nullable * _Nullable)error;
- (BOOL)removeEvent:(AdvTKEvent *)event error:(NSError * _Nullable * _Nullable)error;
@end

NS_ASSUME_NONNULL_END
