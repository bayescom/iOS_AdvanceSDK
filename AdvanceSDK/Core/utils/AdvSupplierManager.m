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

/// 是否是走的本地的渠道
@property (nonatomic, assign) BOOL isLoadLocalSupplier;

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
- (void)loadDataWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId {
    self.mediaId = mediaId;
    self.adspotId = adspotId;
    
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
        [self reportWithType:AdvanceSdkSupplierRepoLoaded];
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
        
        // 执行非CPT渠道逻辑
        [self notCPTLoadNextSuppluer:_supplierM.firstObject error:nil];
    }
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
    
    _currSupplier = supplier;
    [_supplierM removeObject:_currSupplier];
    [self reportWithType:AdvanceSdkSupplierRepoLoaded];
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
    [self reportWithType:AdvanceSdkSupplierRepoLoaded];
    if ([_delegate respondsToSelector:@selector(advSupplierLoadSuppluer:error:)]) {
        [_delegate advSupplierLoadSuppluer:_baseSupplier error:nil];
    }
    [_supplierM removeObject:_currSupplier];
}

// MARK: ======================= Net Work =======================
/// 拉取线上数据 如果是仅仅储存 不会触发任何回调，仅存储策略信息
- (void)fetchData:(BOOL)saveOnly {
    _mediaId = @"";
    NSMutableDictionary *deviceInfo = [AdvDeviceInfoUtil getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
//    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@?adspotid=%@", AdvanceSdkRequestUrl, _adspotId]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.fetchTime];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
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
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_103].toNSError];
        }
        
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
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_105].toNSError];
        }
        
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
- (void)reportWithUploadArr:(NSArray<NSString *> *)uploadArr {
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
- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType {
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadArr = _currSupplier.loadedtk;
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
        uploadArr =  _currSupplier.failedtk;
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在
        return;
    }
    // 执行上报请求
    [self reportWithUploadArr:uploadArr];
    ADVLog(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), _currSupplier.name);
}

// MARK: ======================= get =======================
- (NSTimeInterval)fetchTime {
    if (_fetchTime <= 0) {
        _fetchTime = 5;
    }
    return _fetchTime;
}

@end
