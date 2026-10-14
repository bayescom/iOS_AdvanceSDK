#import "AdvTKEventStore.h"
#import "AdvTKEvent.h"
#import "AdvLog.h"
#if __has_include(<sqlite3.h>)
#import <sqlite3.h>
#else
#import "sqlite3.h"
#endif

@interface AdvTKEventStore () {
    sqlite3 *_database;
}
@property (nonatomic, copy) NSString *path;
@property (nonatomic, assign) BOOL loaded;
@end

@implementation AdvTKEventStore

- (instancetype)initWithPath:(NSString *)path {
    if (self = [super init]) _path = [path.stringByStandardizingPath copy];
    return self;
}

- (BOOL)fail:(NSError **)error message:(NSString *)message {
    if (error) *error = [NSError errorWithDomain:@"com.advancesdk.tk.storage" code:1
                                      userInfo:@{NSLocalizedDescriptionKey: message}];
    return NO;
}

- (BOOL)databaseFailed:(NSError **)error code:(int)code {
    NSString *detail = [NSString stringWithUTF8String:_database ? sqlite3_errmsg(_database) : sqlite3_errstr(code)];
    if (error) *error = [NSError errorWithDomain:@"com.advancesdk.tk.storage.sqlite" code:code
                                      userInfo:@{NSLocalizedDescriptionKey: detail ?: @"TK 数据库操作失败"}];
    return NO;
}

- (BOOL)executeSQL:(const char *)sql error:(NSError **)error {
    int result = sqlite3_exec(_database, sql, NULL, NULL, NULL);
    return result == SQLITE_OK ? YES : [self databaseFailed:error code:result];
}

- (void)closeDatabase {
    if (_database) sqlite3_close_v2(_database);
    _database = NULL;
}

- (BOOL)openWithError:(NSError **)error {
    if (_database) return YES;
    if (![NSFileManager.defaultManager createDirectoryAtPath:self.path withIntermediateDirectories:YES attributes:nil error:error]) return NO;
    NSURL *directory = [NSURL fileURLWithPath:self.path isDirectory:YES];
    if (![directory setResourceValue:@YES forKey:NSURLIsExcludedFromBackupKey error:error]) return NO;

    // 这里只打开数据库；是否重建由启动恢复入口根据错误类型决定。
    NSString *file = [self.path stringByAppendingPathComponent:@"tk.sqlite"];
    int result = sqlite3_open_v2(file.fileSystemRepresentation, &_database, SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE, NULL);
    if (result != SQLITE_OK) {
        [self databaseFailed:error code:result];
        [self closeDatabase];
        return NO;
    }
    const char *schema =
        "PRAGMA journal_mode = WAL; PRAGMA synchronous = NORMAL;"
        "CREATE TABLE IF NOT EXISTS tk_events (task_id TEXT PRIMARY KEY NOT NULL, payload BLOB NOT NULL);"
        "CREATE TABLE IF NOT EXISTS tk_quarantine (id INTEGER PRIMARY KEY, task_id TEXT NOT NULL, payload BLOB NOT NULL,"
        " reason TEXT NOT NULL, created_at REAL NOT NULL);";
    if (![self executeSQL:schema error:error]) {
        [self closeDatabase];
        return NO;
    }
    return YES;
}

- (BOOL)quarantineRow:(sqlite3_int64)rowID error:(NSError **)error {
    if (![self executeSQL:"BEGIN IMMEDIATE" error:error]) return NO;
    // 直接备份原始行再删除，两步在同一事务内完成；任何一步失败都回滚。
    sqlite3_stmt *statement = NULL;
    int result = sqlite3_prepare_v2(_database,
        "INSERT INTO tk_quarantine (task_id, payload, reason, created_at)"
        " SELECT task_id, payload, 'Invalid task data', ? FROM tk_events WHERE rowid = ?", -1, &statement, NULL);
    if (result == SQLITE_OK) result = sqlite3_bind_double(statement, 1, NSDate.date.timeIntervalSince1970);
    if (result == SQLITE_OK) result = sqlite3_bind_int64(statement, 2, rowID);
    if (result == SQLITE_OK) result = sqlite3_step(statement);
    if (result != SQLITE_DONE) [self databaseFailed:error code:result];
    sqlite3_finalize(statement);
    if (result == SQLITE_DONE) {
        statement = NULL;
        result = sqlite3_prepare_v2(_database, "DELETE FROM tk_events WHERE rowid = ?", -1, &statement, NULL);
        if (result == SQLITE_OK) result = sqlite3_bind_int64(statement, 1, rowID);
        if (result == SQLITE_OK) result = sqlite3_step(statement);
        if (result != SQLITE_DONE) [self databaseFailed:error code:result];
        sqlite3_finalize(statement);
    }
    if (result != SQLITE_DONE || ![self executeSQL:"COMMIT" error:error]) {
        [self executeSQL:"ROLLBACK" error:NULL];
        return NO;
    }
    AdvLog(@"AdvTK 已隔离损坏任务，rowid=%lld", rowID);
    return YES;
}

- (NSArray<AdvTKEvent *> *)loadEventsWithError:(NSError **)error {
    NSError *loadError = nil;
    NSArray<AdvTKEvent *> *events = [self readEventsWithError:&loadError];
    int code = (int)loadError.code & 0xff;
    // 仅启动恢复时处理明确的数据库损坏；锁、权限、磁盘满和 I/O 错误保留原库重试。
    if (!events && [loadError.domain isEqualToString:@"com.advancesdk.tk.storage.sqlite"] &&
        (code == SQLITE_CORRUPT || code == SQLITE_NOTADB)) {
        [self closeDatabase];
        AdvLog(@"AdvTK 启动时数据库损坏，将丢弃历史任务并重建：%@", loadError.localizedDescription);
        // 关闭连接后清理专用目录及附属文件；清理失败不提前创建新库。
        if (![NSFileManager.defaultManager removeItemAtPath:self.path error:&loadError]) {
            if (error) *error = loadError;
            return nil;
        }
        loadError = nil;
        events = [self readEventsWithError:&loadError]; // 本次只重建一次，失败交给既有存储重试。
    }
    if (!events && error) *error = loadError;
    return events;
}

- (NSArray<AdvTKEvent *> *)readEventsWithError:(NSError **)error {
    self.loaded = NO;
    if (![self openWithError:error]) return nil;
    sqlite3_stmt *statement = NULL;
    int result = sqlite3_prepare_v2(_database, "SELECT rowid, task_id, payload FROM tk_events", -1, &statement, NULL);
    if (result != SQLITE_OK) {
        [self databaseFailed:error code:result];
        sqlite3_finalize(statement);
        return nil;
    }
    NSMutableArray *events = [NSMutableArray array];
    NSMutableArray<NSNumber *> *invalidRows = [NSMutableArray array];
    while ((result = sqlite3_step(statement)) == SQLITE_ROW) {
        const char *bytes = (const char *)sqlite3_column_text(statement, 1);
        NSString *taskId = bytes ? [[NSString alloc] initWithBytes:bytes length:(NSUInteger)sqlite3_column_bytes(statement, 1)
                                                        encoding:NSUTF8StringEncoding] : nil;
        const void *raw = sqlite3_column_blob(statement, 2);
        int length = sqlite3_column_bytes(statement, 2);
        NSData *data = length ? [NSData dataWithBytes:raw length:(NSUInteger)length] : NSData.data;
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:NULL];
        AdvTKEvent *event = [AdvTKEvent eventWithDictionary:payload];
        if (event && [event.taskId isEqualToString:taskId]) [events addObject:event];
        else [invalidRows addObject:@(sqlite3_column_int64(statement, 0))];
    }
    // 先完整读完再处理坏记录，不能把 SQLite 读取失败当成空队列或坏 JSON。
    if (result != SQLITE_DONE) [self databaseFailed:error code:result];
    sqlite3_finalize(statement);
    if (result != SQLITE_DONE) return nil;
    for (NSNumber *rowID in invalidRows) {
        if (![self quarantineRow:rowID.longLongValue error:error]) return nil;
    }
    self.loaded = YES;
    return events;
}

// 每个任务独占一行；更新或删除时不读取、不改写其他任务。data 为 nil 表示删除。
- (BOOL)writeData:(NSData *)data taskId:(NSString *)taskId error:(NSError **)error {
    if (!self.loaded) return [self fail:error message:@"TK 存储尚未恢复"];
    const char *sql = data ? "INSERT OR REPLACE INTO tk_events (task_id, payload) VALUES (?, ?)" :
                             "DELETE FROM tk_events WHERE task_id = ?";
    sqlite3_stmt *statement = NULL;
    int result = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
    if (result == SQLITE_OK) result = sqlite3_bind_text(statement, 1, taskId.UTF8String, -1, SQLITE_TRANSIENT);
    if (data && result == SQLITE_OK) result = sqlite3_bind_blob64(statement, 2, data.bytes, data.length, SQLITE_TRANSIENT);
    if (result == SQLITE_OK) result = sqlite3_step(statement);
    if (result != SQLITE_DONE) [self databaseFailed:error code:result];
    sqlite3_finalize(statement);
    return result == SQLITE_DONE;
}

- (BOOL)saveEvent:(AdvTKEvent *)event error:(NSError **)error {
    NSData *data = [NSJSONSerialization dataWithJSONObject:event.dictionaryRepresentation options:0 error:error];
    return data && [self writeData:data taskId:event.taskId error:error];
}

- (BOOL)removeEvent:(AdvTKEvent *)event error:(NSError **)error {
    return [self writeData:nil taskId:event.taskId error:error];
}

- (void)dealloc {
    [self closeDatabase];
}

@end
