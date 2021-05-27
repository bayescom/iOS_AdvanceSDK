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
#import "AdvModel.h"
#import "AdvAdsportInfoUtil.h"
@interface AdvSupplierManager ()
@property (nonatomic, strong) AdvSupplierModel *model;

// 可执行渠道
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *supplierM;
// 打底渠道
//@property (nonatomic, strong) AdvSupplier *baseSupplier;
// 当前加载的渠道
//@property (nonatomic, weak) AdvSupplier *currSupplier;

/// 媒体id
@property (nonatomic, copy) NSString *mediaId;
/// 广告位id
@property (nonatomic, copy) NSString *adspotId;
/// reqid
@property (nonatomic, copy) NSString *reqid;
/// 自定义拓展字段
@property (nonatomic, strong) NSDictionary *ext;

/// 是否是走的本地的渠道
@property (nonatomic, assign) BOOL isLoadLocalSupplier;

@property (nonatomic, assign) NSTimeInterval serverTime;


@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSLock *lock;



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
    AdvSupplier *currentSupplier = _supplierM.firstObject;
    // 不管是不是并行渠道, 到了该执行的时候 必须要按照串行渠道的逻辑去执行
    currentSupplier.isParallel = NO;
    NSInteger currentPriority = currentSupplier.priority;

    [self notCPTLoadNextSuppluer:currentSupplier error:nil];

    if (self.model.setting.parallelGroup.count > 0) {
        // 并行执行
        [self parallelActionWithCurrentPriority:currentPriority];
    }
}

- (void)loadNextSupplier {
    if (self.model == nil) {
        // 执行打底渠道
//        [self doBaseSupplierIfHas];
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }


        return;
    }
    // 判断是否在CPT时间段
    NSTimeInterval curTime = [[NSDate date] timeIntervalSince1970]*1000.0;
    if ([self.model.setting.cptStart floatValue] < curTime && [self.model.setting.cptEnd floatValue] > curTime) {
        
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
            if (supplier.identifier == self.model.setting.cptSupplier) {
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
        
        [self reportWithType:AdvanceSdkSupplierRepoLoaded supplier:targetSupplier error:nil];
        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
            [_delegate advSupplierLoadSuppluer:targetSupplier error:nil];
        }
    } else {
        // 非包天 model无渠道信息
        if (self.model.suppliers.count <= 0) {
            // 执行打底渠道
            if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
                [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_116].toNSError];
            }

            return;
        }

        
        // 执行非CPT渠道逻辑
        AdvSupplier *currentSupplier = _supplierM.firstObject;
        NSInteger currentPriority = currentSupplier.priority;
        
        [self notCPTLoadNextSuppluer:currentSupplier error:nil];
        
        if (self.model.setting.parallelGroup.count > 0) {
            // 并行执行
            [self parallelActionWithCurrentPriority:currentPriority];
        }
    }
}

// 并行执行
- (void)parallelActionWithCurrentPriority:(NSInteger)priority {
    NSNumber *currentPriority = [NSNumber numberWithInteger:priority];
    NSDictionary *ext = [self.ext mutableCopy];
    NSString *adTypeName = [ext valueForKey:AdvSdkTypeAdName];

    NSMutableArray *groupM = [self.model.setting.parallelGroup mutableCopy];
    if (self.model.setting.parallelGroup.count > 0) {
        // 利用currentPriority 匹配priorityGroup 看看当中有没有需要和当前的supplier 并发的渠道
        __weak typeof(self) _self = self;
        [groupM enumerateObjectsUsingBlock:^(NSMutableArray<NSNumber *> * _Nonnull prioritys, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(_self) self = _self;
            if (!self) {
                return;
            }
            // 如果这个优先级组里 包含了当前渠道的优先级 则循环执行 然后删除这个组
            if ([prioritys containsObject:currentPriority]) {
                for (NSInteger i = 0; i < prioritys.count; i++) {
                    NSInteger priority = [prioritys[i] integerValue];
                    AdvSupplier *parallelSupplier = [self getSupplierByPriority:priority];
                    
                    BOOL isSupportParallel = [AdvAdsportInfoUtil isSupportParallelWithAdTypeName:adTypeName supplierId:parallelSupplier.identifier];

                    if (isSupportParallel && // 该广告位支持并行
                        parallelSupplier.priority != [currentPriority integerValue] &&// 并且不是currentSupplier
                        parallelSupplier) {
                        parallelSupplier.isParallel = YES;
                        [self notCPTLoadNextSuppluer:parallelSupplier error:nil];
                    }
                }
                
                [self.model.setting.parallelGroup removeObject:prioritys];
                
                *stop = YES;
            }
        }];
    }

}

// 根据优先级查询_supplierM中的渠道
- (AdvSupplier *)getSupplierByPriority:(NSInteger)priority {
    for (NSInteger i = 0 ; i < _supplierM.count; i++) {
        AdvSupplier *supplier = _supplierM[i];
        if (supplier.priority == priority) {
            return supplier;
        }
    }
    return nil;
}

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
    
    
    if (supplier.isParallel) {
        
    } else {
//        NSLog(@"展示队列优先级: %ld", (long)supplier.priority);
        [self.lock lock];
        [_supplierM removeObject:supplier];
        [self.lock unlock];
//        NSLog(@"展示队列: %@", _supplierM);
    }
    
    ADVLog(@"当前执行的渠道:%@ 是否并行:%d 优先级:%ld name:%@", supplier, supplier.isParallel, (long)supplier.priority, supplier.name);

    
    // 如果成功或者失败 就意味着 该并行渠道有结果了, 所以不需要改变状态了
    // 正在加载中的时候 表明并行渠道正在加载 只要等待就可以了所以也不需要改变状态
    if (supplier.state == AdvanceSdkSupplierStateFailed || supplier.state == AdvanceSdkSupplierStateSuccess || supplier.state == AdvanceSdkSupplierStateInPull) {
        // 只有并行的渠道才有可能走到这里 因为只有并行渠道才会 有成功失败请求中的状态 串行渠道 执行的时候已经从_supplierM移除了
        
        
    } else {
        supplier.state = AdvanceSdkSupplierStateInHand;
        [self reportWithType:AdvanceSdkSupplierRepoLoaded supplier:supplier error:nil];
    }
    
    if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
        [_delegate advSupplierLoadSuppluer:supplier error:error];
    }
}

/// 设置打底渠道
//- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
//                                adspotId:(NSString *)adspotid
//                                mediaKey:(NSString *)mediakey
//                                   sdkId:(nonnull NSString *)sdkid {
//    _baseSupplier = [AdvSupplier supplierWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
//}

/// 执行兜底渠道
//- (void)doBaseSupplierIfHas {
//    if (_baseSupplier == nil) {
//        // 未设置打底渠道
//        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
//            [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_110].toNSError];
//        }
//        return;
//    }
//    else if (_currSupplier == _baseSupplier) {
//        // 当前执行了打底渠道了 则报错
//        if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
//            [_delegate advSupplierLoadSuppluer:nil error:[AdvError errorWithCode:AdvErrorCode_114].toNSError];
//        }
//        return;
//    }
//    _currSupplier = _baseSupplier;
//    [self reportWithType:AdvanceSdkSupplierRepoLoaded supplier:_baseSupplier error:nil];
//    if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
//        [_delegate advSupplierLoadSuppluer:_baseSupplier error:nil];
//    }
//    [_supplierM removeObject:_currSupplier];
//}

// MARK: ======================= Net Work =======================
/// 拉取线上数据 如果是仅仅储存 不会触发任何回调，仅存储策略信息
- (void)fetchData:(BOOL)saveOnly {
    NSMutableDictionary *deviceInfo = [AdvDeviceInfoUtil getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    
    if (self.ext) {
        
        // 如果是缓存渠道 请求的时候要标记一下
        if (_isLoadLocalSupplier) {
            [self.ext setValue:@"1" forKey:@"cache_effect"];
        }
        
        [deviceInfo setValue:self.ext forKey:@"ext"];
    }
    
    // caid 有就传没有就不穿
//    NSDictionary *config = [AdvSdkConfig shareInstance].caidConfig;
//    if (config) {
//        NSString *caid = [config valueForKey:AdvSdkConfigCAID];
//        if (caid) {
//            [deviceInfo setValue:caid forKey:@"caid"];
//        }
//    }
    
    // 个性化广告推送开关
    [deviceInfo setValue:[AdvSdkConfig shareInstance].isAdTrack ? @"0" : @"1" forKey:@"donottrack"];
    self.reqid = [AdvDeviceInfoUtil getAuctionId];
    if (self.reqid) {
        [deviceInfo setValue:self.reqid forKey:@"reqid"];
    }

    sleep(4.5);
    ADVLog(@"请求参数 %@   uuid:%@", deviceInfo, [AdvDeviceInfoUtil getAuctionId]);
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
    ADVLog(@"开始请求 %f", [[NSDate date] timeIntervalSince1970]);
    self.dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ADVLog(@"请求完成 %f", [[NSDate date] timeIntervalSince1970]);
            [self doResultData:data response:response error:error saveOnly:saveOnly];
        });
    }];
    [self.dataTask resume];
}

- (void)cacelDataTask {
    if (self.dataTask) {
        [self.dataTask cancel];
    }
    self.model = nil;
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
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_103 obj:error].toNSError];
        }


        // 默认走打底
//        ADVLog(@"statusCode != 200，执行打底");
//        [self doBaseSupplierIfHas];
        return;
    }
    
    NSError *parseErr = nil;
    AdvSupplierModel *a_model = [AdvSupplierModel adv_modelWithJSON:data];
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
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_105 obj:error].toNSError];
        }

//        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
//            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_105].toNSError];
//        }
        
        // 默认走打底
//        ADVLog(@"model.code != 200，执行打底");
//        [self doBaseSupplierIfHas];
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
    ADVLog(@"---------");
    if (!saveOnly) {
        self.model = a_model;
        
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
        
        ADVLog(@"TEST %@", a_model.setting.parallelGroup);
        // 开始执行策略
        [self loadNextSupplier];
    }
    [a_model saveData:data];
}

/// 数据上报
- (void)reportWithUploadArr:(NSArray<NSString *> *)uploadArr error:(NSError *)error{
    for (id obj in uploadArr) {
        @try {
            NSString *urlString = obj;
            urlString = [self paramValueOfUrl:obj withParam:@"&reqid"];
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
        if ([error.domain isEqualToString:@"BDAdErrorDomain"]) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_bd_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"com.pangle.buadsdk"]) { // 新版穿山甲sdk报错
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=err_csj_%ld&track_time",(long)error.code]];
        } else if ([error.domain isEqualToString:@"com.bytedance.buadsdk"]) {// 穿山甲sdk报错
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
        NSString *loadedtk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoLoaded];
        [temp addObject:loadedtk];
    }
    return temp;
}

#pragma imptk 的参数拼接
- (NSMutableArray *)imptkUrlWithArr:(NSArray<NSString *> *)uploadArr {
    NSMutableArray *temp = [NSMutableArray arrayWithCapacity:uploadArr.count];
    for (id obj in uploadArr.mutableCopy) {
        NSString *loadedtk = [self joinTimeUrlWithObj:obj type:AdvanceSdkSupplierRepoImped];
        [temp addObject:loadedtk];
    }
    return temp;
}

/// 拼接时间戳
/// @param urlString url
/// @param type AdvanceSdkSupplierRepoType
- (NSString *)joinTimeUrlWithObj:(NSString *)urlString type:(AdvanceSdkSupplierRepoType)repoType {
    NSTimeInterval serverTime = [[NSDate date] timeIntervalSince1970]*1000 - self.serverTime;
    if (serverTime > 0) {
        if (repoType == AdvanceSdkSupplierRepoLoaded) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=l_%.0f&track_time",serverTime]];
        } else if (repoType == AdvanceSdkSupplierRepoImped) {
            return [urlString stringByReplacingOccurrencesOfString:@"&track_time" withString:[NSString stringWithFormat:@"&t_msg=tt_%.0f&track_time",serverTime]];
        }
    }
    return urlString;
}

- (NSString *)paramValueOfUrl:(NSString *)url withParam:(NSString *)param {
    @try {
        if ([url containsString:param]) {
            NSRange range =  [url rangeOfString:param];
            
            // 定义要删除按的reqid
            NSString *reqidValue = [NSString stringWithFormat:@"reqid=%@", self.reqid];
            
            // 找到原url当中 reqid=balabalabala
            NSRange rangeReq = NSMakeRange(range.location + 1, 38);
            NSString * parametersString = [url substringWithRange:rangeReq];
    //        [url  substringFromIndex:range.location];
            if ([parametersString containsString:@"&"]) { // reqid=balabalabala 包含了& 说明截取不准确返回的url有问题 则不进行替换工作
                return url;
            }
            url = [url stringByReplacingOccurrencesOfString:parametersString withString:reqidValue];
        }
    } @catch (NSException *exception) {
        return url;
    }
    return url;
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
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(nonnull NSError *)error{
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadArr = [self loadedtkUrlWithArr:supplier.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadArr =  supplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceeded) {
        uploadArr =  supplier.succeedtk;
        // 曝光成功 更新本地策略
        if (_isLoadLocalSupplier) {
            ADVLog(@"曝光成功 此次使用本地缓存 更新本地策略");
            [self fetchData:YES];
        }
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  [self imptkUrlWithArr:supplier.imptk];
    } else if (repoType == AdvanceSdkSupplierRepoFaileded) {
        uploadArr =  [self failedtkUrlWithArr:supplier.failedtk error:error];
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在
        return;
    }
    // 执行上报请求
    [self reportWithUploadArr:uploadArr error:error];
    ADVLog(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), supplier.name);
}

// MARK: ======================= get =======================
- (NSTimeInterval)fetchTime {
    if (_fetchTime <= 0) {
        _fetchTime = 5;
    }
    return _fetchTime;
}

- (NSLock *)lock {
    if (!_lock) {
        _lock = [NSLock new];
    }
    return _lock;
}

- (void)setModel:(AdvSupplierModel *)model {
    if (_model != model) {
        ADVLog(@"%@ -- %@", _model, model);
        _model = nil;
        ADVLog(@"%@ -- %@", _model, model);
        _model = model;
        ADVLog(@"model赋值 %@ %@", _model, model);
    }
}
@end
