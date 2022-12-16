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
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvSupplierManager ()
{
    NSInteger _incomeWaterfallCount;
    NSInteger _waterfallMinPrice;

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

@property (nonatomic, strong) NSMutableArray *arrayWaterfall;
@property (nonatomic, strong) NSMutableArray *arrayHeadBidding;


/// 计时器检测bidding时间
@property (nonatomic, strong) CADisplayLink *timeoutCheckTimer;
/// bidding截止时间戳
@property (nonatomic, assign) NSInteger timeout_stamp;


/// 广告数据data
@property (nonatomic, strong) NSData *adData;

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
    _mediaId = mediaId;
    _adspotId = adspotId;
    _tkUploadTool = [[AdvUploadTKUtil alloc] init];
    _ext = [ext mutableCopy];
    _arrayHeadBidding = [NSMutableArray array];
    _arrayWaterfall = [NSMutableArray array];
    
    
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

- (void)loadDataWithSupplierModel:(AdvSupplierModel *)model {
    if (!self.arrayHeadBidding) {
        self.arrayHeadBidding = [NSMutableArray array];
    }
    
    if (!self.arrayWaterfall) {
        self.arrayWaterfall = [NSMutableArray array];
    }

    self.model = model;
    self.model.setting.bidding_type = 0;
    self.supplierM = [self.model.suppliers mutableCopy];
    [self sortSupplierMByPriority];

    [self loadWaterfallSupplierAction];
    
}

- (void)loadNextSupplierIfHas {
    // 执行非CPT渠道逻辑
    AdvSupplier *currentSupplier = _supplierM.lastObject;
    // 不管是不是并行渠道, 到了该执行的时候 必须要按照串行渠道的逻辑去执行
    currentSupplier.isParallel = NO;
//    NSInteger currentPriority = currentSupplier.priority;
//    NSLog(@"%s %@", __func__, currentSupplier.sdktag);
    [self notCPTLoadNextSuppluer:currentSupplier error:nil];

//    if (_model.setting.parallelGroup.count > 0) {
//        // 并行执行
//        [self parallelActionWithCurrentPriority:currentPriority];
//    }
}

// 开始下一组bidding
- (void)loadNextWaterfallSupplierIfHas {
//    NSLog(@"------------>>>>>>>");
    // 取当前bidding组里次优先胜出的广告
    AdvSupplier *currentSupplier = self.arrayWaterfall.lastObject;
    currentSupplier.isParallel = NO;
    
    if (currentSupplier) {// 如果有 继续执行
//        NSLog(@"%s %@",__func__, currentSupplier.sdktag);
        [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    } else {
        [self.arrayWaterfall removeAllObjects];
        _waterfallMinPrice = 0;
        [self loadWaterfallSupplierAction];
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
        [self GMBiddingAction];

    } else {
        // head_bidding_group为参与bidding的渠道分组 parallel_group为普通瀑布流的分组
        // 目前聚合里所有的广告位adapter的逻辑都是返回价格就取返回的价格, 没有返回的价格就取supplier里填写的价格
        // 综上, ios端所有的广告位都一样 本质不区分是否bidding  只是单纯的对价格进行比较并择机展现
        
        
        // 执行瀑布流的逻辑
        [self loadWaterfallSupplierAction];
//         执行bidding组的逻辑
//        [self loadBiddingSupplierAction];
    }
}


// 开启GMbidding
- (void)GMBiddingAction {
    AdvSupplier *GMObj = [AdvSupplier new];
    
    GMObj.mediaid = self.model.gro_more.gromore_params.appid;
    GMObj.adspotid = self.model.gro_more.gromore_params.adspotid;
    GMObj.timeout = self.model.gro_more.gromore_params.timeout;
    GMObj.identifier = SDK_ID_BIDDING;
    GMObj.isParallel = NO;
    GMObj.name = @"实时竞价";
    GMObj.sdktag = @"Bidding";
    GMObj.imptk = self.model.gro_more.gmtk.imptk;
    GMObj.loadedtk = self.model.gro_more.gmtk.loadedtk;
    GMObj.failedtk = self.model.gro_more.gmtk.failedtk;
    GMObj.succeedtk = self.model.gro_more.gmtk.succeedtk;
    GMObj.imptk = self.model.gro_more.gmtk.imptk;
    GMObj.biddingtk = self.model.gro_more.gmtk.biddingtk;
    GMObj.clicktk = self.model.gro_more.gmtk.clicktk;

    // 初始化 biddingCongfig单例
    id biddingConfig = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString(@"AdvBiddingCongfig"), @selector(defaultManager));
    // 将策略Model 付给BiddingCongfig 用来在customAdapter里初始化新的开屏广告位
    [biddingConfig performSelector:@selector(setAdDataModel:adspotId:) withObject:self.model withObject:self.adspotId];
    [self notCPTLoadNextSuppluer:GMObj error:nil];


}

// 开始Waterfall的逻辑
- (void)loadWaterfallSupplierAction {
    // 参加Waterfall的渠道
    NSMutableArray *tempWaterfall = [NSMutableArray array];
    
    // 目前参加Waterfall分层的方式去执行渠道
    NSMutableArray *waterfallPriority = self.model.setting.parallelGroup.firstObject;
    __weak typeof(self) _self = self;
    [waterfallPriority enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull priority, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(_self) self = _self;
        // 想要分组并发->广告位必须要支持并发->必须支持load 和show 分离
        AdvSupplier *parallelSupplier = [self getSupplierByPriority:[priority integerValue]];
        // 该广告位支持并行
        if (![tempWaterfall containsObject:parallelSupplier] &&// tempBidding 不包含这个渠道
            parallelSupplier != nil) {
            
            parallelSupplier.isParallel = YES;// 并发执行这些渠道
            parallelSupplier.positionType = AdvanceSdkSupplierTypeWaterfall;///<==============
            [tempWaterfall addObject:parallelSupplier];
        }
    }];
    
    [_model.setting.parallelGroup removeObject:waterfallPriority];
    
    // 将headBidding的渠道 标记好后加入到tempWaterfall 中 一起并发
    // 加入到tempWaterfall 之后 需要把headBiddingGroup 的元素置空, 避免第二层开始的时候 又重复添加, 因为headBidding只和第一层对比
    NSMutableArray *biddingSuppiers = [NSMutableArray array];
    biddingSuppiers = self.model.setting.headBiddingGroup;
    
    [biddingSuppiers enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull priority, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(_self) self = _self;
        // 执行bidding组的Supplier parallelSupplier
        AdvSupplier *biddingSupplier = [self getSupplierByPriority:[priority integerValue]];
        biddingSupplier.isParallel = YES;// 并发执行这些渠道
        biddingSupplier.positionType = AdvanceSdkSupplierTypeHeadBidding;///<==============
        [tempWaterfall addObject:biddingSupplier];
//        [self notCPTLoadNextSuppluer:biddingSupplier error:nil];
    }];
    
    [self.model.setting.headBiddingGroup removeAllObjects];

    // tempWaterfall = 0意味着所有parallelGroup 的渠道都没展现 这个时候 _incomeWaterfallCount应置为0, 避免卡住问题
    if (tempWaterfall.count > 0) {
        _incomeWaterfallCount = tempWaterfall.count + self.arrayHeadBidding.count;
    } else {
        _incomeWaterfallCount = 0;
    }
    // 参与bidding的渠道数

//    NSLog(@"_incomeWaterfallCount = %ld", _incomeWaterfallCount);
    if (_incomeWaterfallCount == 0) {// 没有参加bidding的渠道即没有并发, 那么就按照旧的业务去执行
        if (self.model.setting.parallelGroup.count == 0) { // 如果并发组里元素个数为0 那么就开始执行剩下非并发的渠道了
            [self loadNextSupplier];
        } else {// 如果并发组里元素个数不为0 那么就开始执行下一层的bidding渠道
            [self loadNextWaterfallSupplierIfHas];
        }
        
    } else {
        
        // Waterfall开始
        if (self.delegate && [self.delegate respondsToSelector:@selector(advManagerBiddingActionWithSuppliers:)]) {
            [self.delegate advManagerBiddingActionWithSuppliers:tempWaterfall];
            
        }
        
        if (_timeoutCheckTimer) {
            [self deallocTimer];
        }
        
        NSInteger parallel_timeout = _model.setting.parallel_timeout;
        if (parallel_timeout == 0) {
            parallel_timeout = 3000;
        }
        
        _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + (parallel_timeout / 1000))*1000;
        // 开启定时器监听过期
        [_timeoutCheckTimer invalidate];

        _timeoutCheckTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeoutCheckTimerAction)];
        [_timeoutCheckTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

        // 一起并发
        
        __weak typeof(self) _self = self;
        [tempWaterfall enumerateObjectsUsingBlock:^(AdvSupplier  *_Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
            __strong typeof(_self) self = _self;
            supplier.isParallel = YES;// 并发执行这些渠道
//            supplier.positionType = AdvanceSdkSupplierTypeWaterfall;
//            NSLog(@"-->%s tag %@ %@ %d", __func__,supplier, supplier.sdktag, supplier.isParallel);
            [self notCPTLoadNextSuppluer:supplier error:nil];
        }];
        
    }

}

// 开启bidding的逻辑
- (void)loadBiddingSupplierAction {
    if (self.model.setting.headBiddingGroup.count == 0) {
        ADV_LEVEL_INFO_LOG(@"没有竞价渠道");
        return;
    }
    
    NSMutableArray *biddingSuppiers = [NSMutableArray array];
    biddingSuppiers = self.model.setting.headBiddingGroup;
    
    __weak typeof(self) _self = self;
    [biddingSuppiers enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull priority, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(_self) self = _self;
        // 执行bidding组的Supplier parallelSupplier
        AdvSupplier *biddingSupplier = [self getSupplierByPriority:[priority integerValue]];
        biddingSupplier.isParallel = YES;// 并发执行这些渠道
        biddingSupplier.positionType = AdvanceSdkSupplierTypeHeadBidding;
        [self notCPTLoadNextSuppluer:biddingSupplier error:nil];
    }];

}

// 进入bidding队列
- (void)inWaterfallQueueWithSupplier:(AdvSupplier *)supplier {
    if (!supplier) {
        return;
    }
    
    // 返回广告的渠道价格比 _waterfallMinPrice 低 就做替换
    // 目的是 在waterfall 每层结束的时候 就要知道这层的最低价格
    NSInteger price = (supplier.supplierPrice > 0) ? supplier.supplierPrice : supplier.sdk_price;
//    NSLog(@"===> %ld %ld", price, _waterfallMinPrice);
    // 0是初始值
    // 当_waterfallMinPrice 为初始值或者 price 更小时 才对_waterfallMinPrice赋值
    if (price < _waterfallMinPrice || _waterfallMinPrice == 0) {
        _waterfallMinPrice = price;
    }
//    NSLog(@"===> %ld %ld", price, _waterfallMinPrice);
    [self.arrayWaterfall addObject:supplier];
    
    // 如果所有并发渠道都有结果返回了 则选择price高的渠道展示
//    NSLog(@"%@", self.arrayWaterfall.count);
//    NSLog(@"_incomeWaterfallCount = %ld  arrayWaterfall.count = %ld arrayHeadBidding.count = %ld", _incomeWaterfallCount, _arrayWaterfall.count, _arrayHeadBidding.count);
    if (self.arrayWaterfall.count + self.arrayHeadBidding.count == _incomeWaterfallCount) {
        [self _sortSuppliersByPrice:self.arrayWaterfall];
    }
}

// 进入HeadBidding队列
- (void)inHeadBiddingQueueWithSupplier:(AdvSupplier *)supplier {
    if (!supplier) {
        return;
    }
    [self.arrayHeadBidding addObject:supplier];
    
//    NSLog(@"===2=> %ld  %ld %ld", (long)_incomeWaterfallCount, self.arrayWaterfall.count, self.arrayHeadBidding.count);
    if (self.arrayWaterfall.count + self.arrayHeadBidding.count == _incomeWaterfallCount) {
        [self _sortSuppliersByPrice:self.arrayWaterfall];
    }

}

// 错误渠道接受
- (void)inParallelWithErrorSupplier:(AdvSupplier *)errorSupplier {
    if (!errorSupplier) {
        return;
    }
    
//    NSLog(@"====> %ld", (long)_incomeWaterfallCount);
    if (_incomeWaterfallCount > 0) {
        _incomeWaterfallCount = _incomeWaterfallCount - 1;
        // 每层总
//        NSLog(@"===1=> %ld  %ld %ld", (long)_incomeWaterfallCount, self.arrayWaterfall.count, self.arrayHeadBidding.count);
        if (self.arrayWaterfall.count + self.arrayHeadBidding.count == _incomeWaterfallCount) {
            [self _sortSuppliersByPrice:self.arrayWaterfall];
        }
    }
}

// 检测时间戳, 如果bidding截止 那么就把当前返回广告的渠道
- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
//        NSLog(@"检测时间截止");
//        NSLog(@"===111=> %ld  %ld %ld", (long)_incomeWaterfallCount, self.arrayWaterfall.count, self.arrayHeadBidding.count);
        [self _sortSuppliersByPrice:self.arrayWaterfall];
    }
}

// bidding渠道按价格排序
- (void)_sortSuppliersByPrice:(NSMutableArray <AdvSupplier *> *)suppliers {
    
    // 停止检测时间戳
    [self deallocTimer];
    
    if (suppliers.count == 0) {
        [self loadNextWaterfallSupplierIfHas];
        return;
    }
    
    
    // 将bidding组的结果 加入suppliers当中
    // 加入规则:
    // 1: 大于本组最低价格的才能加入,
    // 2: 加入完之后 要从bidding队列里移除
    // 3: 加入到suppliers的广告位 positionType 需切换到AdvanceSdkSupplierTypeWaterfall
    NSMutableArray *tempBidding = [self.arrayHeadBidding mutableCopy];
    
//    NSLog(@"suppliers = %@",suppliers);
//    NSLog(@"arrayHeadBidding = %@",self.arrayHeadBidding);
    __weak typeof(self) _self = self;
    [tempBidding enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong typeof(_self) self = _self;
//        NSLog(@"=1=> %ld  %ld", obj.supplierPrice, _waterfallMinPrice);
        NSInteger obj_price = (obj.supplierPrice > 0) ? obj.supplierPrice : obj.sdk_price;
        if (obj_price >= _waterfallMinPrice) {
            [suppliers addObject:obj];
            [self.arrayHeadBidding removeObject:obj];
        }
    }];
    
//    NSLog(@"suppliers = %@",suppliers);
//    NSLog(@"arrayHeadBidding = %@",self.arrayHeadBidding);

//     价格由低到高排序
//    NSLog(@"------1111111-> %@  %ld %ld", suppliers[0].sdktag, (long)obj11.supplierPrice, (long)obj11.priority);
    [suppliers sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
        __strong typeof(_self) self = _self;
        AdvSupplier *obj11 = obj1;
        AdvSupplier *obj22 = obj2;
        
        NSInteger obj11_price = (obj11.supplierPrice > 0) ? obj11.supplierPrice : obj11.sdk_price;
        NSInteger obj22_price = (obj22.supplierPrice > 0) ? obj22.supplierPrice : obj22.sdk_price;
//        NSLog(@"------obj11_price-> %@  %ld %ld", obj11.sdktag, (long)obj11.supplierPrice, (long)obj11.priority);
//        NSLog(@"------obj22_price-> %@  %ld %ld", obj22.sdktag, (long)obj22.supplierPrice, (long)obj22.priority);

        obj11.supplierPrice = obj11_price;
        obj22.supplierPrice = obj22_price;
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
    
//    for (AdvSupplier *temp in suppliers) {
//        NSLog(@"------1-> %@ %ld %ld %ld", temp.sdktag, (long)temp.sdk_price, (long)temp.supplierPrice, (long)temp.priority);
//    }
//
//    for (AdvSupplier *temp in self.arrayHeadBidding) {
//        NSLog(@"------2-> %@ %ld %ld %ld", temp.sdktag, (long)temp.sdk_price, (long)temp.supplierPrice, (long)temp.priority);
//    }


    // 取价格最高的渠道执行
    AdvSupplier *currentSupplier = suppliers.lastObject;
    currentSupplier.isParallel = NO;
    currentSupplier.positionType = AdvanceSdkSupplierTypeWaterfall;
    // bidding结束
    if (self.delegate && [self.delegate respondsToSelector:@selector(advManagerBiddingEndWithWinSupplier:)]) {
        [self.delegate advManagerBiddingEndWithWinSupplier:currentSupplier];
    }
//    NSLog(@"%s %@ %ld",__func__, currentSupplier.sdktag, currentSupplier.sdk_price);
    [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    // 执行的都从 arrayWaterfall里面删除
    [self.arrayWaterfall removeObject:currentSupplier];

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
    

    [self sortSupplierMByPriority];
    AdvSupplier *currentSupplier = _supplierM.lastObject;
    currentSupplier.isParallel = NO;
    currentSupplier.positionType = AdvanceSdkSupplierTypeWaterfall;
    // bidding结束
    if (self.delegate && [self.delegate respondsToSelector:@selector(advManagerBiddingEndWithWinSupplier:)]) {
        [self.delegate advManagerBiddingEndWithWinSupplier:currentSupplier];
    }

    
    //         NSLog(@"%s %@", __func__, currentSupplier.sdktag);
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
                    
                    if (parallelSupplier.priority != [currentPriority integerValue] &&// 并且不是currentSupplier
                        parallelSupplier) {
                        parallelSupplier.isParallel = YES;
//                        NSLog(@"%s %@", __func__, parallelSupplier.sdktag);
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
        if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]) {
            [self.lock lock];
            [_supplierM removeAllObjects];
            [self.lock unlock];

        } else {
            [self.lock lock];
            [_supplierM removeObject:supplier];
            [self.lock unlock];

        }
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
    ADV_LEVEL_INFO_LOG(@"执行过后执行的渠道:%@ 是否并行:%d 优先级:%ld name:%@", supplier, supplier.isParallel, (long)supplier.priority, supplier.name);

}


// MARK: ======================= Net Work =======================
/// 拉取线上数据 如果是仅仅储存 不会触发任何回调，仅存储策略信息
- (void)fetchData:(BOOL)saveOnly {
    NSMutableDictionary *deviceInfo = [[AdvDeviceInfoUtil sharedInstance] getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    
    if (self.ext) {
        
        // 如果是缓存渠道 请求的时候要标记一下
        if (_isLoadLocalSupplier) {
            [self.ext setValue:@"1" forKey:@"cache_effect"];
        }
        
        [deviceInfo setValue:self.ext forKey:@"ext"];
        
        ADV_LEVEL_INFO_LOG(@"自定义扩展字段 ext : %@", self.ext);
    }
    // 1200411781 5073996413293680
    
    ADV_LEVEL_INFO_LOG(@"请求参数 %@", deviceInfo);
    NSLog(@"%@", [self jsonStringCompactFormatForDictionary:deviceInfo]);
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
//    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestMockUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.fetchTime];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    
    self.tkUploadTool.serverTime = [[NSDate date] timeIntervalSince1970]*1000;

    
    ADV_LEVEL_INFO_LOG(@"开始请求时间戳: %f", [[NSDate date] timeIntervalSince1970]);
    
    __weak typeof(self) weakSelf = self;
    self.dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        __strong typeof(self) strongSelf = weakSelf;//第一层
        __weak typeof(self) weakSelf2 = strongSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            __strong typeof(self) strongSelf2 = weakSelf2;//第二层
            ADV_LEVEL_INFO_LOG(@"请求完成时间戳: %f", [[NSDate date] timeIntervalSince1970]);
//            ADVTRACK(self.mediaId, self.adspotId, AdvTrackEventCase_getAction);
            [strongSelf2 doResultData:data response:response error:error saveOnly:saveOnly];
        });
        
    }];
    [self.dataTask resume];
}


- (NSString *)jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}

- (void)cacelDataTask {
    if (_dataTask) {
        [_dataTask cancel];
    }
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
        ADV_LEVEL_ERROR_LOG(@"statusCode != 200, 策略返回出错");
//        [self doBaseSupplierIfHas];
        return;
    }
    
    NSError *parseErr = nil;
    AdvSupplierModel *a_model = [AdvSupplierModel adv_modelWithJSON:data];
    NSLog(@"[JSON]%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
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
        self.adData = data;
        _supplierM = [_model.suppliers mutableCopy];
        [self sortSupplierMByPriority];
        
        if ([_delegate respondsToSelector:@selector(advSupplierManagerLoadSuccess:)]) {
            [_delegate advSupplierManagerLoadSuccess:self.model];
        }
                
        // 现在全都走新逻辑
        [self loadBiddingSupplier];
    }
}


// MARK: ======================= Private =======================
- (void)sortSupplierMByPriority {
    if (_supplierM.count > 1) {
        [self.supplierM sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
            
            AdvSupplier *obj11 = obj1;
            AdvSupplier *obj22 = obj2;
            
            NSInteger obj11_price = (obj11.supplierPrice > 0) ? obj11.supplierPrice : obj11.sdk_price;
            NSInteger obj22_price = (obj22.supplierPrice > 0) ? obj22.supplierPrice : obj22.sdk_price;
    //        NSLog(@"------obj11_price-> %@  %ld %ld", obj11.sdktag, (long)obj11.supplierPrice, (long)obj11.priority);
    //        NSLog(@"------obj22_price-> %@  %ld %ld", obj22.sdktag, (long)obj22.supplierPrice, (long)obj22.priority);

            obj11.supplierPrice = obj11_price;
            obj22.supplierPrice = obj22_price;
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
//        for (AdvSupplier *temp in self.supplierM) {
//            NSLog(@"------3-> %@ %ld %ld %ld", temp.sdktag, (long)temp.sdk_price, (long)temp.supplierPrice, (long)temp.priority);
//        }

//        [_supplierM sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
//            AdvSupplier *obj11 = obj1;
//            AdvSupplier *obj22 = obj2;
//            if (obj11.priority > obj22.priority) {
//                return NSOrderedDescending;
//            } else if (obj11.priority == obj22.priority) {
//                return NSOrderedSame;
//            } else {
//                return NSOrderedAscending;
//            }
//        }];
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

        uploadArr =  [self.tkUploadTool succeedtkUrlWithArr:supplier.succeedtk price:(supplier.supplierPrice == 0) ? supplier.sdk_price : supplier.supplierPrice];
        // 曝光成功 更新本地策略
        if (_isLoadLocalSupplier) {
            ADV_LEVEL_INFO_LOG(@"曝光成功 此次使用本地缓存 更新本地策略");
            [self fetchData:YES];
        }
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  [self.tkUploadTool imptkUrlWithArr:supplier.imptk price:(supplier.supplierPrice == 0) ? supplier.sdk_price : supplier.supplierPrice];
    } else if (repoType == AdvanceSdkSupplierRepoFaileded) {
        
        
        uploadArr =  [self.tkUploadTool failedtkUrlWithArr:supplier.failedtk error:error];
        
    } else if (repoType == AdvanceSdkSupplierRepoGMBidding) {
        uploadArr =  [self.tkUploadTool imptkUrlWithArr:supplier.biddingtk price:(supplier.supplierPrice == 0) ? supplier.sdk_price : supplier.supplierPrice];
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

- (void)setModel:(AdvSupplierModel *)model {
    if (_model != model) {
        _model = nil;
        _model = model;
    }
}

- (void)setArrayWaterfall:(NSMutableArray *)arrayWaterfall {
    if (_arrayWaterfall != arrayWaterfall) {
        _arrayWaterfall = nil;
        _arrayWaterfall = arrayWaterfall;
    }
}

- (void)setArrayHeadBidding:(NSMutableArray *)arrayHeadBidding {
    if (_arrayHeadBidding != arrayHeadBidding) {
        _arrayHeadBidding = nil;
        _arrayHeadBidding = arrayHeadBidding;
    }
}

- (void)deallocTimer {
    [_timeoutCheckTimer invalidate];
    _timeoutCheckTimer = nil;
    _timeout_stamp = 0;
}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
    [self deallocTimer];
    [self cacelDataTask];
    _tkUploadTool = nil;
    [_arrayWaterfall removeAllObjects];
    _arrayWaterfall = nil;
    [_arrayHeadBidding removeAllObjects];
    _arrayHeadBidding = nil;
    [_supplierM removeAllObjects];
    _supplierM = nil;
    _model = nil;

}
@end
