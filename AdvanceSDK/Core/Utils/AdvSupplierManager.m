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
#import "AdvUploadTKUtil.h"
#import "AdvTrackEventUtil.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvSupplierManager ()
{
    NSInteger _incomeBiddingCount;
}
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
/// 自定义拓展字段
@property (nonatomic, strong) NSDictionary *ext;

/// 是否是走的本地的渠道
@property (nonatomic, assign) BOOL isLoadLocalSupplier;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;
@property (nonatomic, strong) NSLock *lock;


@property (nonatomic, strong) AdvUploadTKUtil *tkUploadTool;

@property (nonatomic, strong) NSMutableArray *arrayWaitingBidding;


/// 计时器检测bidding时间
@property (nonatomic, strong) CADisplayLink *timeoutCheckTimer;
/// bidding截止时间戳
@property (nonatomic, assign) NSInteger timeout_stamp;

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
    self.tkUploadTool = [[AdvUploadTKUtil alloc] init];
    self.ext = [ext mutableCopy];
    
    // 获取本地数据
    _model = [AdvSupplierModel loadDataWithMediaId:mediaId adspotId:adspotId];
    
//    ADVTRACK(self.mediaId, self.adspotId, AdvTrackEventCase_getInfo);
    
    
    // 是否实时
    if (!_model.setting.useCache) {
        _model = nil;
        ADV_LEVEL_INFO_LOG(@"无本地策略");
    }

    // 是否超时
    if (_model.setting.cacheTime > 0) {
        if (_model.setting.cacheTime <= [[NSDate date] timeIntervalSince1970]) {
            [_model clearLocalModel];
            _model = nil;
            ADV_LEVEL_INFO_LOG(@"无本地策略");
        }
    }
    
    
    
    
    // model不存在
    if (!_model) {
        ADV_LEVEL_INFO_LOG(@"本地策略不可用，拉取线上策略");
        _isLoadLocalSupplier = NO;
        [self fetchData:NO];
    } else {
        _isLoadLocalSupplier = YES;
        ADV_LEVEL_INFO_LOG(@"执行本地策略");
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
        // 开始执行策略
        [self loadBiddingSupplier];
    }
}

- (void)loadNextSupplierIfHas {
    // 执行非CPT渠道逻辑
    AdvSupplier *currentSupplier = _supplierM.firstObject;
    // 不管是不是并行渠道, 到了该执行的时候 必须要按照串行渠道的逻辑去执行
    currentSupplier.isParallel = NO;
//    NSInteger currentPriority = currentSupplier.priority;

    [self notCPTLoadNextSuppluer:currentSupplier error:nil];

//    if (_model.setting.parallelGroup.count > 0) {
//        // 并行执行
//        [self parallelActionWithCurrentPriority:currentPriority];
//    }
}

// 开始下一组bidding
- (void)loadNextBiddingSupplierIfHas {
    
    // 取当前bidding组里次优先胜出的广告
    AdvSupplier *currentSupplier = self.arrayWaitingBidding.lastObject;
    currentSupplier.isParallel = NO;
    
    if (currentSupplier) {// 如果有 继续执行
        [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    } else {
        [self.arrayWaitingBidding removeAllObjects];
        [self loadBiddingSupplierAction];
    }

    
}

// - (void)advManagerBiddingActionWithSuppliers:(NSMutableArray <AdvSupplier*>*)suppliers;

- (void)loadBiddingSupplier {
    if (_model == nil) {
        ADV_LEVEL_ERROR_LOG(@"策略请求失败");
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }


        return;
    }
    
    
    // 如果用 bidding功能
    if (_model.setting.bidding_type == 1) {
        // 根据渠道标识 获取bidding的supplier去执行
        
        [_supplierM enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.identifier isEqualToString:SDK_ID_BIDDING]) {
                *stop = YES;
                obj.isParallel = NO;
                
                // 初始化 biddingCongfig单例
                id biddingConfig = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString(@"AdvBiddingCongfig"), @selector(defaultManager));
                // 将策略Model 付给BiddingCongfig 用来在customAdapter里初始化新的开屏广告位
                [biddingConfig performSelector:@selector(setAdDataModel:) withObject:self.model];

                [self notCPTLoadNextSuppluer:obj error:nil];
            }
        }];
    } else {
        [self loadBiddingSupplierAction];
    }
}

// 开始bidding的逻辑
- (void)loadBiddingSupplierAction {
    /// 确认哪些渠道参加bidding
    NSDictionary *ext = [self.ext mutableCopy];
    NSString *adTypeName = [ext valueForKey:AdvSdkTypeAdName];

    // 参加bidding的渠道
    NSMutableArray *tempBidding = [NSMutableArray array];
    
    // 目前参加bidding的一定放在并发组的第一组里
    NSMutableArray *biddingPriority = self.model.setting.parallelGroup.firstObject;
    
    [biddingPriority enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull priority, NSUInteger idx, BOOL * _Nonnull stop) {
        // 想要bidding->广告位必须要支持并发->必须支持load 和show 分离
        AdvSupplier *parallelSupplier = [self getSupplierByPriority:[priority integerValue]];
        BOOL isSupportParallel = [AdvAdsportInfoUtil isSupportParallelWithAdTypeName:adTypeName supplierId:parallelSupplier.identifier];
        if (isSupportParallel && // 该广告位支持并行
            ![tempBidding containsObject:parallelSupplier] &&// tempBidding 不包含这个渠道
            parallelSupplier != nil) {
            
            parallelSupplier.isParallel = YES;// 并发执行这些渠道
            parallelSupplier.isSupportBidding = YES;// 并且支持bidding
            [tempBidding addObject:parallelSupplier];
        }
    }];
    
    [_model.setting.parallelGroup removeObject:biddingPriority];

    // 参与bidding的渠道数
    _incomeBiddingCount = tempBidding.count;

    NSLog(@"_incomeBiddingCount = %ld", _incomeBiddingCount);
    if (_incomeBiddingCount == 0) {// 没有参加bidding的渠道即没有并发, 那么就按照旧的业务去执行
        if (self.model.setting.parallelGroup.count == 0) { // 如果并发组里元素个数为0 那么就开始执行剩下非并发的渠道了
            [self loadNextSupplier];
        } else {// 如果并发组里元素个数不为0 那么就开始执行下一层的bidding渠道
            [self loadNextBiddingSupplierIfHas];
        }
        
    } else {
        
        // bidding开始
        if (self.delegate && [self.delegate respondsToSelector:@selector(advManagerBiddingActionWithSuppliers:)]) {
            [self.delegate advManagerBiddingActionWithSuppliers:tempBidding];
            
        }
        
        // 记录过期的时间
        _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + _model.setting.parallel_timeout / 1000)*1000;
        // 开启定时器监听过期
        [_timeoutCheckTimer invalidate];

        _timeoutCheckTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeoutCheckTimerAction)];
        [_timeoutCheckTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

        // 一起并发
        [tempBidding enumerateObjectsUsingBlock:^(AdvSupplier  *_Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
            // isParallel和isSupportBidding 这两个字段在上面已经设置过了 所以这里不用再设置了
//            supplier.isParallel = YES;// 并发执行这些渠道
//            supplier.isSupportBidding = YES;// 并且支持bidding
            [self notCPTLoadNextSuppluer:supplier error:nil];
        }];
        
    }

}

// 进入bidding队列
- (void)inBiddingQueueWithSupplier:(AdvSupplier *)supplier {
    
    [self.arrayWaitingBidding addObject:supplier];
    
    // 如果所有并发渠道都有结果返回了 则选择price高的渠道展示
//    NSLog(@"%@", self.arrayWaitingBidding.count);
    NSLog(@"_incomeBiddingCount = %ld  arrayWaitingBidding.count = %ld", _incomeBiddingCount, _arrayWaitingBidding.count);
    if (self.arrayWaitingBidding.count == _incomeBiddingCount) {
        [self _sortSuppliersByPrice:self.arrayWaitingBidding];
    }
}

// 检测时间戳, 如果bidding截止 那么就把当前返回广告的渠道
- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
//        NSLog(@"检测时间截止");
        [self _sortSuppliersByPrice:self.arrayWaitingBidding];
    }
}

// bidding渠道按价格排序
- (void)_sortSuppliersByPrice:(NSMutableArray <AdvSupplier *> *)suppliers {
    // 如果规定时间内 bidding没有返回结果, 那么判定此次bidding失败,
    // 目前失败直接往外抛异常回调, 后续可能会在bidding失败后走之前的逻辑
    
    
    // 停止检测时间戳
    [self deallocTimer];
    
    if (suppliers.count == 0) {
        [self loadNextBiddingSupplierIfHas];
        return;
    }
    
    
    // 价格由低到高排序
    [suppliers sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        
        AdvSupplier *obj11 = obj1;
        AdvSupplier *obj22 = obj2;
        
        CGFloat obj11_price = (obj11.supplierPrice > 0) ? obj11.supplierPrice : obj11.sdk_price;
        CGFloat obj22_price = (obj22.supplierPrice > 0) ? obj22.supplierPrice : obj22.sdk_price;
        
        if (obj11_price > obj22_price) {
            return NSOrderedDescending;
        } else if (obj11_price  == obj22_price) {
            if (obj11.priority > obj22.priority) {// 价格相同的话 按照优先级排序
                return NSOrderedAscending;
            } else if (obj11.priority == obj22.priority) {
                return NSOrderedSame;
            } else {
                return NSOrderedDescending;
            }
        } else {
            return NSOrderedAscending;
        }
    }];
    
    for (AdvSupplier *temp in suppliers) {
        NSLog(@"------1-> %@  %ld %ld", temp.sdktag, (long)temp.supplierPrice, (long)temp.priority);
    }

    // 取价格最高的渠道执行
    AdvSupplier *currentSupplier = suppliers.lastObject;
    currentSupplier.isParallel = NO;
    
    // bidding结束
    if (self.delegate && [self.delegate respondsToSelector:@selector(advManagerBiddingEndWithWinSupplier:)]) {
        [self.delegate advManagerBiddingEndWithWinSupplier:currentSupplier];
    }

    [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    // 执行的都从 arrayWaitingBidding里面删除
    [self.arrayWaitingBidding removeObject:currentSupplier];

}


- (void)loadNextSupplier {
    if (_model == nil) {
        ADV_LEVEL_ERROR_LOG(@"策略请求失败");
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }


        return;
    }
   
        // 非包天 model无渠道信息
        if (_model.suppliers.count <= 0) {
            
            if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
                [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_116].toNSError];
            }

            return;
        }

        
        AdvSupplier *currentSupplier = _supplierM.firstObject;
        
        [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    
}

// 并行执行
- (void)parallelActionWithCurrentPriority:(NSInteger)priority {
    NSNumber *currentPriority = [NSNumber numberWithInteger:priority];
    NSDictionary *ext = [self.ext mutableCopy];
    NSString *adTypeName = [ext valueForKey:AdvSdkTypeAdName];

    NSMutableArray *groupM = [_model.setting.parallelGroup mutableCopy];
    if (_model.setting.parallelGroup.count > 0) {
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
                
                [_model.setting.parallelGroup removeObject:prioritys];
                
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
    
    ADV_LEVEL_INFO_LOG(@"当前执行的渠道:%@ 是否并行:%d 优先级:%ld name:%@", supplier, supplier.isParallel, (long)supplier.priority, supplier.name);

    
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
        
        ADV_LEVEL_INFO_LOG(@"自定义扩展字段 ext : %@", self.ext);
    }
    
    
    ADV_LEVEL_INFO_LOG(@"请求参数 %@   uuid:%@", deviceInfo, [AdvDeviceInfoUtil getAuctionId]);
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
//    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestMockUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.fetchTime];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    
    self.tkUploadTool.serverTime = [[NSDate date] timeIntervalSince1970]*1000;
    NSString *reqid = [AdvDeviceInfoUtil getAuctionId];
    if (reqid) {
        self.tkUploadTool.reqid = reqid;
    }

    
    ADV_LEVEL_INFO_LOG(@"开始请求时间戳: %f", [[NSDate date] timeIntervalSince1970]);
    
    self.dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ADV_LEVEL_INFO_LOG(@"请求完成时间戳: %f", [[NSDate date] timeIntervalSince1970]);
//            ADVTRACK(self.mediaId, self.adspotId, AdvTrackEventCase_getAction);
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
    ADVLogJSONData(data);

    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    if (httpResp.statusCode != 200) {
        // code no statusCode
        if (!saveOnly && [_delegate respondsToSelector:@selector(advSupplierManagerLoadError:)]) {
            [_delegate advSupplierManagerLoadError:[AdvError errorWithCode:AdvErrorCode_103 obj:error].toNSError];
        }


        // 默认走打底
        ADV_LEVEL_ERROR_LOG(@"statusCode != 200, 策略返回出错");
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
        ADV_LEVEL_ERROR_LOG(@"策略解析出错");
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
        ADV_LEVEL_ERROR_LOG(@"statusCode != 200, 策略返回出错");
//        [self doBaseSupplierIfHas];
        return;
    }
    
    // success
    a_model.advMediaId = self.mediaId;
    a_model.advAdspotId = self.adspotId;
    
    // 当使用缓存 但未赋值默认缓存时间 赋值缓存时间为3天
    if (a_model.setting.cacheDur <= 0 && a_model.setting.useCache) {
        // 使用缓存，但未设置缓存时间(使用默认时间3day)
        ADV_LEVEL_INFO_LOG(@"使用缓存，但未设置缓存时间(使用默认时间3day)");
        a_model.setting.cacheDur = 24 * 60 * 60 * 3;
    }
    
    // 记录缓存过期时间
    a_model.setting.cacheTime = [[NSDate date] timeIntervalSince1970] + a_model.setting.cacheDur;
//    ADVLog(@"---------");
    if (!saveOnly) {
        self.model = a_model;
        
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
                
        // 现在全都走新逻辑
        [self loadBiddingSupplier];
    }
    [a_model saveData:data];
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
        uploadArr = [self.tkUploadTool loadedtkUrlWithArr:supplier.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadArr =  supplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceeded) {
        uploadArr =  supplier.succeedtk;
        // 曝光成功 更新本地策略
        if (_isLoadLocalSupplier) {
            ADV_LEVEL_INFO_LOG(@"曝光成功 此次使用本地缓存 更新本地策略");
            [self fetchData:YES];
        }
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  [self.tkUploadTool imptkUrlWithArr:supplier.imptk];
    } else if (repoType == AdvanceSdkSupplierRepoFaileded) {
        uploadArr =  [self.tkUploadTool failedtkUrlWithArr:supplier.failedtk error:error];
    }
    if (!uploadArr || uploadArr.count <= 0) {
        // TODO: 上报地址不存在
        return;
    }
    // 执行上报请求
    [self.tkUploadTool reportWithUploadArr:uploadArr error:error];
    ADV_LEVEL_INFO_LOG(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), supplier.name);
}

- (AdvUploadTKUtil *)tkUploadTool {
    if (!_tkUploadTool) {
        _tkUploadTool = [AdvUploadTKUtil new];
    }
    return _tkUploadTool;
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

- (NSMutableArray *)arrayWaitingBidding {
    if (!_arrayWaitingBidding) {
        _arrayWaitingBidding = [NSMutableArray array];
    }
    return _arrayWaitingBidding;
}

- (void)setModel:(AdvSupplierModel *)model {
    if (_model != model) {
        _model = nil;
        _model = model;
    }
}

- (void)deallocTimer {
    [_timeoutCheckTimer invalidate];
    _timeoutCheckTimer = nil;
    _timeout_stamp = 0;
}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"mgr 释放啦");
    [self deallocTimer];
    self.model = nil;
    self.tkUploadTool = nil;
}
@end
