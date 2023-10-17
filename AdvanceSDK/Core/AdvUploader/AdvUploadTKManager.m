//
//  AdvUploadTKManager.m
//  AdvanceSDK
//
//  Created by MS on 2021/8/20.
//

#import "AdvUploadTKManager.h"
#import "AdvURLSessionOperation.h"
#import "AdvLog.h"
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
        [self.queue addOperation:[self _createSessionOperationWithUrl:url urls:temp uploadFails:uploadFails sign:sign uploadCount:0 complete:completeBlock fail:failBlock]];
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

/// 上传任务
/// @param urlString 被上传的url
/// @param urls 所有待上传的url
/// @param uploadFails 上传失败的容器(目前没用, 未来可能做失败缓存上传)
/// @param sign 本组上传的标志
/// @param count urlString被上传的次数, 目前是失败后上传3次 如果还失败,则无视,不做失败缓存
/// @param completeBlock 成功回调
/// @param failBlock 失败回调

- (AdvURLSessionOperation *)_createSessionOperationWithUrl:(NSString *)urlString
                                                     urls:(NSMutableArray *)urls
                                              uploadFails:(NSMutableArray *)uploadFails
                                                     sign:(NSString *)sign
                                               uploadCount:(NSInteger)count
                                                  complete:(AdvUploadTkComplete)completeBlock
                                                     fail:(AdvUploadTkFail)failBlock {
    
    __block NSInteger tempCount = count;

    NSMutableURLRequest *request = [self createRequestWithUrl:urlString];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    ADVLog(@"\r\nTK上报===>>%@", urlString);
    AdvURLSessionOperation *operation = [[AdvURLSessionOperation alloc] initWithSession:session request:request completionHandler:^(NSData * _Nonnull data, NSURLResponse * _Nonnull response, NSError * _Nonnull error) {
        // 1. 无论成功失败 只要有结果就移除
        if ([urls containsObject:urlString]) {
            [urls removeObject:urlString];
        }
        
        // 2. 如果有失败的 把url保存在容器里 并回调出去
        //    便于后续版本做缓存上报的功能
        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            // 添加进失败容器
            [uploadFails addObject:urlString];
            if (tempCount < 2) {// 说明已经失败过两次了 不用在上传了
                tempCount++;
                [self.queue addOperation:[self _createSessionOperationWithUrl:urlString urls:urls uploadFails:uploadFails sign:sign uploadCount:tempCount complete:completeBlock fail:failBlock]];
            }
            
            // 重新
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
