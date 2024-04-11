//
//  AdvURLSessionOperation.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

#import "AdvURLSessionOperation.h"

#define ADVKVOBlock(KEYPATH, BLOCK) \
    [self willChangeValueForKey:KEYPATH]; \
    BLOCK(); \
    [self didChangeValueForKey:KEYPATH];

@implementation AdvURLSessionOperation{
    BOOL _finished;
    BOOL _executing;
}

- (instancetype)initWithSession:(NSURLSession *)session URL:(NSURL *)url completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _task = [session dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;//第一层
            __weak typeof(self) weakSelf2 = strongSelf;

            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf2 = weakSelf2;//第二层
                [strongSelf2 completeOperationWithBlock:completionHandler data:data response:response error:error];
            });

        }];
    }
    return self;
}

- (instancetype)initWithSession:(NSURLSession *)session request:(NSURLRequest *)request completionHandler:(void (^)(NSData *data, NSURLResponse *response, NSError *error))completionHandler {
    if (self = [super init]) {
        __weak typeof(self) weakSelf = self;
        _task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            __strong typeof(self) strongSelf = weakSelf;//第一层
            __weak typeof(self) weakSelf2 = strongSelf;

            dispatch_async(dispatch_get_main_queue(), ^{
                __strong typeof(self) strongSelf2 = weakSelf2;//第二层
                [strongSelf2 completeOperationWithBlock:completionHandler data:data response:response error:error];
            });
        }];
    }
    return self;
}

- (void)cancel {
    [super cancel];
    [self.task cancel];
}

- (void)start {
    if (self.isCancelled) {
        ADVKVOBlock(@"isFinished", ^{ _finished = YES; });
        return;
    }
    ADVKVOBlock(@"isExecuting", ^{
        [self.task resume];
        _executing = YES;
    });
}

- (BOOL)isExecuting {
    return _executing;
}

- (BOOL)isFinished {
    return _finished;
}

- (BOOL)isConcurrent {
    return YES;
}

- (void)completeOperationWithBlock:(void (^)(NSData *, NSURLResponse *, NSError *))block data:(NSData *)data response:(NSURLResponse *)response error:(NSError *)error {
    if (block)
        block(data, response, error);
    [self completeOperation];
}

- (void)completeOperation {
    [self willChangeValueForKey:@"isFinished"];
    [self willChangeValueForKey:@"isExecuting"];

    _executing = NO;
    _finished = YES;

    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

@end

