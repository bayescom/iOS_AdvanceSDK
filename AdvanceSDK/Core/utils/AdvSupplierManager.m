//
//  AdvSupplierManager.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvSupplierManager.h"
#import "AdvDeviceInfoUtil.h"
#import "AdvSdkConfig.h"
#import "AdvSupplierModel.h"
#import "AdvError.h"
#import "AdvLog.h"
#import "AdvSupplierQueue.h"
@interface AdvSupplierManager ()
@property (nonatomic, strong) AdvSupplierModel *model;

// 可执行渠道
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *supplierM;
// 打底渠道
@property (nonatomic, strong) AdvSupplier *baseSupplier;
// 当前加载的渠道
@property (nonatomic, weak) AdvSupplier *currSupplier;

/// 媒体id
@property (nonatomic, copy) NSString *mediaId;
/// 广告位id
@property (nonatomic, copy) NSString *adspotId;
/// 自定义拓展字段
@property (nonatomic, strong) NSDictionary *ext;

/// 是否是走的本地的渠道
@property (nonatomic, assign) BOOL isLoadLocalSupplier;

@property (nonatomic, assign) NSTimeInterval serverTime;

@property (nonatomic, strong) NSMutableArray *queues;
@end

@implementation AdvSupplierManager

+ (instancetype)manager {
    AdvSupplierManager *mgr = [AdvSupplierManager new];
    return mgr;
}

/**
 * 同步数据
 * 如果本地存在有效数据，直接加载本地数据
 * 数据不存在则同步数据
 */
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary * _Nonnull)ext {
    self.mediaId = mediaId;
    self.adspotId = adspotId;
    self.ext = [ext mutableCopy];
    
    // 获取本地数据
    _model = [AdvSupplierModel loadDataWithMediaId:mediaId adspotId:adspotId];
    
    // 是否实时
    if (!_model.setting.useCache) {
        _model = nil;
    }

    // 是否超时
    if (_model.setting.cacheTime > 0) {
        if (_model.setting.cacheTime <= [[NSDate date] timeIntervalSince1970]) {
            [_model clearLocalModel];
            _model = nil;
        }
    }
    
    // model不存在
    if (!_model) {
        ADVLog(@"本地策略不可用，拉取线上策略");
        _isLoadLocalSupplier = NO;
        [self fetchData:NO];
    } else {
        _isLoadLocalSupplier = YES;
        ADVLog(@"执行本地策略");
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
        // 开始执行策略
        [self loadNextSupplier];
    }
}

- (void)loadNextSupplierIfHas {
    // 执行非CPT渠道逻辑
    [self notCPTLoadNextSuppluer:_supplierM.firstObject error:nil];
}

- (void)loadNextSupplier {
    if (_model == nil) {
        // 执行打底渠道
        [self doBaseSupplierIfHas];
        return;
    }
    // 判断是否在CPT时间段
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970]*1000.0;
    if ([_model.setting.cptStart floatValue] < curTime && [_model.setting.cptEnd floatValue] > curTime) {
        
        // CPT 无渠道
        if (_supplierM.count <= 0) {
            // 抛异常
            if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
                [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_111].toNSError];
            }
            return;
        }
        
        AdvSupplier *targetSupplier = nil;
        for (AdvSupplier *supplier in _supplierM) {
            if (supplier.identifier == _model.setting.cptSupplier) {
                targetSupplier = supplier;
            }
        }
        
        // CPT 未找到目标渠道
        if (targetSupplier == nil) {
            // 抛异常
            if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
                [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_112].toNSError];
            }
            return;
        }
        
        _currSupplier = targetSupplier;
        [self reportWithType:AdvanceSdkSupplierRepoLoaded error:nil];
        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
            [_delegate advSupplierLoadSuppluer:targetSupplier error:nil];
        }
    } else {
        // 非包天 model无渠道信息
        if (_model.suppliers.count <= 0) {
            // 执行打底渠道
            [self doBaseSupplierIfHas];
            return;
        }
        
        
        
        
        
        
        
        /* * * * * * * * * * * * * * * 待整理代码 * * * * * * * * * * * * * * * * * * * * */
        // 开始执行策略
        
        // 如果priorityMap不为空 则并行请求priorityMap中的渠道
        // priorityMap: 该字段中的渠道和第一优先级渠道并行请求
        if (_model.setting.priorityMap.count > 0) {
            // 1.按照priorityMap分组
            AdvSupplierQueue *parallelOperations = [[AdvSupplierQueue alloc]init];

            NSLog(@"并行策略: %@", parallelOperations);
            __weak __typeof__(self) weakSelf = self;
            [_supplierM enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (idx == 0) {// 优先级最高的那个 先添加进并行渠道队列
                    [parallelOperations.inQueueSuppliers addObject:obj];
                } else {
                    // 其他渠道的需要判断是否添加进并行渠道队列
                    [_model.setting.priorityMap enumerateObjectsUsingBlock:^(AdvPriorityMap * _Nonnull map, NSUInteger mapIdx, BOOL * _Nonnull stop) {
                        // 如果优先级和id 都一样 切并行队列里没有该元素的时候(主要是去重) 则添加进并行渠道
                        if ([map.supid isEqualToString:obj.identifier] &&
                            map.priority == obj.priority &&
                            ![parallelOperations.inQueueSuppliers containsObject:obj]) {
                            
                            [parallelOperations.inQueueSuppliers addObject:obj];
                        } else {
                            AdvSupplierQueue *queue = [[AdvSupplierQueue alloc]init];
                            [queue.inQueueSuppliers addObject:obj];
                            [weakSelf.queues addObject:queue];
                        }
                    }];
                }
                
                // 如果 parallelOperations的count 和 setting.parallelIDS 的count+1 相等 则并行分组完毕 添加到整体队列中
                if (parallelOperations.inQueueSuppliers.count == _model.setting.priorityMap.count + 1) {
                    NSLog(@"并行队列: %@", parallelOperations);
                    [weakSelf.queues insertObject:parallelOperations atIndex:0];
                }
                
            }];
        }
        
        NSLog(@"队列s : %@", self.queues);
        for (NSInteger i = 0 ; i < self.queues.count; i++) {

            for (NSInteger j = 0; j < [[self.queues[i] inQueueSuppliers] count]; j ++) {
                AdvSupplier *temp = [self.queues[i] inQueueSuppliers][j];
                NSLog(@"队列element: %@ %@", temp, temp.sdktag);
            }
        }
        
        
        
        /*
        if (_model.setting.parallelIDS.count > 0) {
            // 1. 按照 parallelIDS 分组
            AdvSupplierQueue *parallelOperations = [[AdvSupplierQueue alloc]init];
            
            [_supplierM enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                // 如果 parallelIDS 包含 obj的id 则添加进并行对象里
                if ([_model.setting.parallelIDS containsObject:obj.identifier]) {
                    [parallelOperations.inQueueSuppliers addObject:obj];

                    // 如果 parallelOperations的count 和 setting.parallelIDS 的count 相等 则并行分组完毕 添加到整体队列中
                    if (parallelOperations.inQueueSuppliers.count == _model.setting.parallelIDS.count) {
                        [self.queues addObject:parallelOperations];
                    }
                } else {
                    // 如果不包含则直接 添加进队列里串行执行
                    AdvSupplierQueue *operation = [[AdvSupplierQueue alloc] init];
                    [operation.inQueueSuppliers addObject:obj];
                    [self.queues addObject:parallelOperations];
                }
            }];
            // 排序完成后 self.queue结构为 [AdvSupplierQueue,AdvSupplierQueue,AdvSupplierQueue]
            // 且每个queue当中的inQueueSuppliers个数可能不一样 个数不为1的是并行请求
        }
        */
        
        [self notCPTLoadNextSuppluerParallel:self.queues[0] error:nil];
        /* * * * * * * * * * * * * * * 待整理代码 * * * * * * * * * * *  * * * * * * * * */


    
        
        
        
        
        // 执行非CPT渠道逻辑
//        [self notCPTLoadNextSuppluer:_supplierM.firstObject error:nil];
    }
}
/* * * * * * * * * * * * * * * 待整理代码 * * * * * * * * * * *  * * * * * * * * */

- (void)notCPTLoadNextSuppluerParallel:(AdvSupplierQueue *)queue error:(nullable NSError *)error {
    NSArray *temp = [queue.inQueueSuppliers mutableCopy];
    for (NSInteger i = 0; i < temp.count; i++) {
        AdvSupplier *supplier = temp[i];
        NSLog(@"aaaaa ---%@", [NSThread currentThread]); // 打印当前线程
        [self notCPTLoadNextSuppluerParallelAction:supplier queue:queue error:nil];
    }
}

- (void)notCPTLoadNextSuppluerParallelAction:(nullable AdvSupplier *)supplier queue:(AdvSupplierQueue *)queue error:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(advSupplierLoadSupplueryyyyy:queue:error:)]) {
        [_delegate advSupplierLoadSupplueryyyyy:supplier queue:queue error:error];
    }

}

/* * * * * * * * * * * * * * * 待整理代码 * * * * * * * * * * *  * * * * * * * * */

/// 非 CPT 执行下个渠道
- (void)notCPTLoadNextSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 非包天 选择渠道执行都失败
    if (supplier == nil || _supplierM.count <= 0) {
        // 抛异常
        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
            [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_114].toNSError];
        }
        return;
    }
    
    _currSupplier = supplier;
    [_supplierM removeObject:_currSupplier];
    [self reportWithType:AdvanceSdkSupplierRepoLoaded error:nil];
    if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
        [_delegate advSupplierLoadSuppluer:supplier error:error];
    }
}

/// 设置打底渠道
- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotid
                                mediaKey:(NSString *)mediakey
                                   sdkId:(nonnull NSString *)sdkid {
    _baseSupplier = [AdvSupplier supplierWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
}

/// 执行兜底渠道
- (void)doBaseSupplierIfHas {
    if (_baseSupplier == nil) {
        // 未设置打底渠道
        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
            [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_110].toNSError];
        }
        return;
    } else if (_currSupplier == _baseSupplier) {
        // 当前执行了打底渠道了 则报错
        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
            [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_114].toNSError];
        }
        return;
    }
    _currSupplier = _baseSupplier;
    [self reportWithType:AdvanceSdkSupplierRepoLoaded error:nil];
    if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
        [_delegate advSupplierLoadSuppluer:_baseSupplier error:nil];
    }
    [_supplierM removeObject:_currSupplier];
}

// MARK: ======================= Net Work =======================
/// 拉取线上数据 如果是仅仅储存 不会触发任何回调，仅存储策略信息
- (void)fetchData:(BOOL)saveOnly {
    NSMutableDictionary *deviceInfo = [AdvDeviceInfoUtil getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    if (self.ext) {
        [deviceInfo setValue:self.ext forKey:@"ext"];
    }
//    [deviceInfo setValue:@"" forKey:@"adspotid"];
//    NSLog(@"请求参数 %@", deviceInfo);
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?adspotid=%@", AdvanceSdkRequestUrl, _adspotId]];
    NSURL *url = [NSURL URLWithString:@"https://mock.yonyoucloud.com/mock/2650/api/v3/eleven"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.fetchTime];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    self.serverTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self doResultData:data response:response error:error saveOnly:saveOnly];
        });
    }];
    [dataTask resume];
}

/// 处理返回的数据
- (void)doResultData:(NSData * )data response:(NSURLResponse *)response error:(NSError *)error saveOnly:(BOOL)saveOnly {
    if (error) {
        // error
        if (saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_101 obj:error].toNSError];
        }
        return;
    }
    
    if (!data || !response) {
        // no result
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }
        return;
    }
    
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    if (httpResp.statusCode != 200) {
        // code no statusCode
        // 策略失败回调和渠道失败回调统一, 当策略失败 但是打底渠道成功时 则不抛错误
//        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
//            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_103].toNSError];
//        }
        
        // 默认走打底
        ADVLog(@"statusCode != 200，执行打底");
        [self doBaseSupplierIfHas];
        return;
    }
    
    NSError *parseErr = nil;
    AdvSupplierModel *a_model = [AdvSupplierModel fromData:data error:&parseErr];
//    ADVLog(@"[JSON]%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
    ADVLogJSONData(data);
    if (parseErr || !a_model) {
        // parse error
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_104 obj:parseErr].toNSError];
        }
        return;
    }
    
    if (a_model.code != 200) {
        // result code not 200
        // 策略失败回调和渠道失败回调统一, 当策略失败 但是打底渠道成功时 则不抛错误
//        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
//            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_105].toNSError];
//        }
        
        // 默认走打底
        ADVLog(@"model.code != 200，执行打底");
        [self doBaseSupplierIfHas];
        return;
    }
    
    // success
    a_model.advMediaId = self.mediaId;
    a_model.advAdspotId = self.adspotId;
    
    // 当使用缓存 但未赋值默认缓存时间 赋值缓存时间为3天
    if (a_model.setting.cacheDur <= 0 && a_model.setting.useCache) {
        // 使用缓存，但未设置缓存时间(使用默认时间3day)
        ADVLog(@"使用缓存，但未设置缓存时间(使用默认时间3day)");
        a_model.setting.cacheDur = 24 * 60 * 60 * 3;
    }
    
    // 记录缓存过期时间
    a_model.setting.cacheTime = [[NSDate date] timeIntervalSince1970] + a_model.setting.cacheDur;
    
    if (!saveOnly) {
        _model = a_model;
        
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
        
        // 开始执行策略
        [self loadNextSupplier];
    }
    [a_model save];
}

/// 数据上报
- (void)reportWithUploadArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error{
    for (id obj in uploadArr) {
        @try {
            NSString *urlString = obj;
            NSTimeInterval timeStamp = [[NSDate dateWithTimeIntervalSinceNow:0] timeIntervalSince1970] * 1000;
            urlString = [urlString stringByReplacingOccurrencesOfString:@"__TIME__" withString:[NSString stringWithFormat:@"%0.0f", timeStamp]];
            NSURL *url = [NSURL URLWithString:urlString];
            NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:
                                            NSURLRequestReloadIgnoringLocalCacheData   timeoutInterval:5];
            request.HTTPMethod = @"GET";
            NSURLSession *sharedSession = [NSURLSession sharedSession];
            NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                              completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
                if (error == nil) {} else {}
            }];
            [dataTask resume];
        } @catch (NSException *exception) {
        } @finally {
        }
    }
}

#pragma failedtk 的参数拼接
- (NSMutableArray *)failedtkUrlWithArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *failed = [self joinFailedUrlWithObj:obj error:error];
        [temp addObject:failed];
    }
    return temp;
}

#pragma 错误码参数拼接
- (NSString *)joinFailedUrlWithObj:(NSString *)urlString error:(NSError *)error {
    ADVLog(@"UPLOAD error: %@", error);
    if (error) {
        if ([error.domain isEqualToString:@"com.bytedance.buadsdk"]) {// 穿山甲sdk报错
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_csj_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"GDTAdErrorDomain"]) {// 广点通
            NSString *url = nil;
            if (error.code == 6000 && error.localizedDescription != nil) {
                
                @try {
                    //过滤字符串前后的空格
                    NSString *errorDescription = [error.localizedDescription stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                    //过滤字符串中间的空格
                    errorDescription = [errorDescription stringByReplacingOccurrencesOfString:@" " withString:@""];
                    ////匹配error.localizedDescription当中的"详细码:"得到的下标
                    NSRange range = [errorDescription rangeOfString:@"详细码:"];
                    // 截取"详细码:"后6位字符串
                    NSString *subCodeString = [errorDescription substringWithRange:NSMakeRange(range.location + range.length, 6)];
                    url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld_%@&track_time",(long)error.code, subCodeString]];
                } @catch (NSException *exception) {
                    url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld&track_time",(long)error.code]];
                }
            } else {
                url = [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_gdt_%ld&track_time",(long)error.code]];
            }
            return url;
        } else {// 倍业
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_mer_%ld&track_time",(long)error.code]];
        }
    }
    return urlString;
}

#pragma loadedtk 的参数拼接
- (NSMutableArray *)loadedtkUrlWithArr:(NSArray<NSString *> *)uploadArr {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *loadedtk = [self joinLoadedtkUrlWithObj:obj];
        [temp addObject:loadedtk];
    }
    return temp;
}

#pragma loadedtk 拼接时间戳
- (NSString *)joinLoadedtkUrlWithObj:(NSString *)urlString {
    NSTimeInterval serverTime = [[NSDate date] timeIntervalSince1970]*1000 - self.serverTime;
    if (serverTime > 0) {
        return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=l_%.0f&track_time",serverTime]];
    }
    return urlString;
}


// MARK: ======================= Private =======================
- (void)sortSupplierMByPriority {
    if (_supplierM.count > 1) {
        [_supplierM sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            AdvSupplier *obj11 = obj1;
            AdvSupplier *obj22 = obj2;
            if (obj11.priority > obj22.priority) {
                return NSOrderedDescending;
            } else if (obj11.priority == obj22.priority) {
                return NSOrderedSame;
            } else {
                return NSOrderedAscending;
            }
        }];
    }
}

// MARK: ======================= 上报 =======================
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType error:(nonnull NSError *)error{
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadArr = [self loadedtkUrlWithArr:_currSupplier.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadArr =  _currSupplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceeded) {
        uploadArr =  _currSupplier.succeedtk;
        // 曝光成功 更新本地策略
        if (_isLoadLocalSupplier) {
            ADVLog(@"曝光成功 此次使用本地缓存 更新本地策略");
            [self fetchData:YES];
        }
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  _currSupplier.imptk;
    } else if (repoType == AdvanceSdkSupplierRepoFaileded) {
        uploadArr =  [self failedtkUrlWithArr:_currSupplier.failedtk error:error];
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在
        return;
    }
    // 执行上报请求
    [self reportWithUploadArr:uploadArr error:error];
    ADVLog(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), _currSupplier.name);
}

// MARK: ======================= get =======================
- (NSTimeInterval)fetchTime {
    if (_fetchTime <= 0) {
        _fetchTime = 5;
    }
    return _fetchTime;
}

- (NSMutableArray *)queues {
    if (!_queues) {
        _queues = [NSMutableArray array];
    }
    return _queues;
}
@end
