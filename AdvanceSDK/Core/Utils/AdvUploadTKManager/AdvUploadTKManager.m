//
//  AdvUploadTKManager.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

#import "AdvUploadTKManager.h"
#import "AdvURLSessionOperation.h"

@interface AdvUploadTKManager ()
@property (nonatomic, strong) NSOperationQueue *queue;

@end

@implementation AdvUploadTKManager

// MARK: ======================= 初始化设置 =======================

static AdvUploadTKManager *defaultManager = nil;

+ (AdvUploadTKManager*)defaultManager {
    static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil) {
            defaultManager = [[self alloc] init];
        }
    });
    return defaultManager;
}

+ (id)allocWithZone:(struct _NSZone *)zone {
   static dispatch_once_t token;
    dispatch_once(&token, ^{
        if(defaultManager == nil) {
            defaultManager = [super allocWithZone:zone];
        }
    });
    return defaultManager;
}
//自定义初始化方法
- (instancetype)init {
    self = [super init];
    if(self) {
        self.queue = [[NSOperationQueue alloc] init];
        self.maxConcurrentOperationCount = 2;
        self.timeoutInterval = 5;
    }
    return self;
}

//覆盖该方法主要确保当用户通过copy方法产生对象时对象的唯一性
- (id)copy {
    return self;
}

//覆盖该方法主要确保当用户通过mutableCopy方法产生对象时对象的唯一性
- (id)mutableCopy {
    return self;
}

//自定义描述信息，用于log详细打印
- (NSString *)description {
    return @"这是倍业聚合SDK中用于上传各广告位生命周期的组件";
}


// MARK: ======================= 设置 =======================

- (void)setMaxConcurrentOperationCount:(NSInteger)maxConcurrentOperationCount {
    _maxConcurrentOperationCount = maxConcurrentOperationCount;
    self.queue.maxConcurrentOperationCount = maxConcurrentOperationCount;
}


// MARK: ======================= Methods =======================

- (void)uploadTKWithUrls:(NSArray *)urls {
    [self uploadTKWithUrls:urls sign:nil complete:nil fail:nil];
}

- (void)uploadTKWithUrls:(NSArray *)urls
                    sign:(NSString *)sign
                 complete:(AdvUploadTkComplete)completeBlock
                    fail:(AdvUploadTkFail)failBlock {
    
    NSMutableArray *temp = [urls mutableCopy];
    NSMutableArray *uploadFails = [NSMutableArray array];
    
    for (NSString *url in urls) {
        [self.queue addOperation:[self createSessionOperationWithUrl:url urls:temp uploadFails:uploadFails sign:sign complete:completeBlock fail:failBlock]];
    }
    
}

- (NSMutableURLRequest *)createRequestWithUrl:(NSString *)urlString {
    if (!urlString) {
        return nil;
    }
    NSURL *url = [NSURL URLWithString:urlString];

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.timeoutInterval];
    
    request.HTTPMethod = @"GET";

    return request;
}

- (AdvURLSessionOperation *)createSessionOperationWithUrl:(NSString *)urlString
                                                     urls:(NSMutableArray *)urls
                                              uploadFails:(NSMutableArray *)uploadFails
                                                     sign:(NSString *)sign
                                                  complete:(AdvUploadTkComplete)completeBlock
                                                     fail:(AdvUploadTkFail)failBlock {
    
    NSMutableURLRequest *request = [self createRequestWithUrl:urlString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];

    AdvURLSessionOperation *operation = [[AdvURLSessionOperation alloc] initWithSession:session request:request completionHandler:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        
        // 1. 无论成功失败 只要有结果就移除
        if ([urls containsObject:urlString]) {
            [urls removeObject:urlString];
        }
        
        // 2. 如果有失败的 把url保存在容器里 并回调出去
        //    便于后续版本做缓存上报的功能
        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            
            [uploadFails addObject:urlString];
            
            if (failBlock) {
                failBlock(urlString, [(NSHTTPURLResponse *)response statusCode]);
            }
        }
        
        // 上传流程结束
        if (urls.count == 0) {
            
            // 失败容器当中没有数据, 则全部成功
            AdvUploadTkCompleteCode completeCode = AdvUploadTkCompleteCode_Succees;
            
            if (uploadFails.count == 0) {
                
                completeCode = AdvUploadTkCompleteCode_Succees;
                
            } else {
                
                completeCode = AdvUploadTkCompleteCode_Completed;
                
            }
            
            if (completeBlock) {
                completeBlock(sign, completeCode);
            }
        }
    }];
    return operation;
}
@end
