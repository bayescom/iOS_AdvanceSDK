//
//  AdvSupplierManager.m
//  Demo
//
//  Created by CherryKing on 2020/11/18.
//

#import "AdvPolicyService.h"
#import "AdvDeviceInfoUtil.h"
#import "AdvPolicyModel.h"
#import "AdvError.h"
#import "AdvLog.h"
#import "AdvUploadTKUtil.h"
#import "NSObject+AdvModel.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSArray+Adv.h"

@interface AdvPolicyService ()
{
    NSInteger _incomeWaterfallCount;
    NSInteger _waterfallMinPrice;

}
@property (nonatomic, strong) AdvPolicyModel *model;

// 可执行渠道
@property (nonatomic, strong) NSMutableArray<AdvSupplier *> *supplierM;
/// 媒体id
@property (nonatomic, copy) NSString *mediaId;
/// 广告位id
@property (nonatomic, copy) NSString *adspotId;
/// 自定义拓展字段
@property (nonatomic, strong) NSDictionary *ext;

/// 是否是走的本地的渠道
@property (nonatomic, assign) BOOL isLoadLocalSupplier;

@property (nonatomic, strong) NSURLSessionDataTask *dataTask;


@property (nonatomic, strong) AdvUploadTKUtil *tkUploadTool;

@property (nonatomic, strong) NSMutableArray *arrayWaterfall;
@property (nonatomic, strong) NSMutableArray *arrayHeadBidding;


/// 计时器检测bidding时间
@property (nonatomic, strong) CADisplayLink *timeoutCheckTimer;
/// bidding截止时间戳
@property (nonatomic, assign) NSInteger timeout_stamp;

@property (nonatomic, assign) BOOL cancelDelay;

/// 已根据优先级排序的第一组渠道
@property (nonatomic, strong) NSMutableArray <AdvSupplier *> *groupedSuppliers;

@end

@implementation AdvPolicyService

+ (instancetype)manager {
    AdvPolicyService *mgr = [AdvPolicyService new];
    return mgr;
}

/// 获取策略数据
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary * _Nonnull)ext {
    _mediaId = mediaId;
    _adspotId = adspotId;
    _ext = [ext mutableCopy];
    _arrayHeadBidding = [NSMutableArray array];
    _arrayWaterfall = [NSMutableArray array];
    
    /// 获取实时策略信息
    [self fetchPolicyData];
}

/// 执行SDK策略
- (void)executeSDKPolicy {
    if (_model.setting.bidding_type == 1) { // gro_more竞价
        // 根据渠道标识 获取bidding的supplier去执行
        [self GMBiddingAction];
    } else { // 混合竞价（传统瀑布流 + 头部竞价）
        [self loadMixedBiddingSuppliers];
    }
}

/// 执行混合竞价模式（传统瀑布流 + 头部竞价）
- (void)loadMixedBiddingSuppliers {
    /// 瀑布流模式，无headbidding渠道
    if (self.model.setting.headBiddingGroup.count == 0) {
        
        /// 策略组无数据说明后台配置错误 或者 所有的组加载广告全部没有成功
        if (self.model.setting.parallelGroup.count == 0) {
            if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
                [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_105].toNSError];
            }
            return;
        }
        
        /// 取parallelGroup当前第一层策略组
        NSArray *firstGroupPriorities = self.model.setting.parallelGroup.firstObject;
        /// 将优先级数组转换成supplier数组
        NSArray *firstGroupSuppliers = [firstGroupPriorities map:^id(NSNumber *priority) {
            return [self.model.suppliers filter:^BOOL(AdvSupplier *supplier) {
                return supplier.priority == priority.integerValue;
            }].firstObject;
        }];
        
        _groupedSuppliers = [firstGroupSuppliers mutableCopy];
        /// 开始执行策略的回调
        if ([_delegate respondsToSelector:@selector(advPolicyServiceStartBiddingWithSuppliers:)]) {
            [_delegate advPolicyServiceStartBiddingWithSuppliers:firstGroupSuppliers];
        }
        /// 并发执行该组广告的请求
        [firstGroupSuppliers enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadAnySupplier:)]) {
                [_delegate advPolicyServiceLoadAnySupplier:supplier];
            }
            [self reportEventWithType:AdvanceSdkSupplierRepoLoaded supplier:supplier error:nil];
        }];
        
        /// 执行完后移除该组渠道，确保再次调用此函数时能获取到下一组渠道
        [self.model.setting.parallelGroup removeObjectAtIndex:0];
        
        /// 该组渠道加载广告超时监测
        [self performSelector:@selector(observeLoadAdTimeout) withObject:nil afterDelay:self.model.setting.parallel_timeout * 1.0 / 1000];
    }
}

/// 超时监测
- (void)observeLoadAdTimeout {
    /// check方法中对_groupedSuppliers进行了移除操作，所以创建超时数组避免边遍历边移除带来问题
    NSArray *timeoutSuppliers = [self.groupedSuppliers filter:^BOOL(AdvSupplier *supplier) {
        return supplier.loadAdState == AdvanceSupplierLoadAdReady;
    }];
    [timeoutSuppliers enumerateObjectsUsingBlock:^(AdvSupplier *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkTargetWithResultfulSupplier:obj loadAdState:AdvanceSupplierLoadAdTimeout];
    }];
}

/// [Public func]检测是否命中用于展示的渠道
/// - Parameters:
///   - supplier: loadAd后返回结果的某个渠道
///   - state: loadAd后返回结果状态
- (void)checkTargetWithResultfulSupplier:(AdvSupplier *)supplier loadAdState:(AdvanceSupplierLoadAdState)state {
    
    /// 监测超时的方法中已经执行了本方法，所以超时后渠道返回的数据直接丢弃
    if (supplier.loadAdState == AdvanceSupplierLoadAdTimeout) {
        return;
    }
    
    supplier.loadAdState = state;
    switch (state) {
        case AdvanceSupplierLoadAdFailed:
        case AdvanceSupplierLoadAdTimeout:
            /// 移除失败和超时的渠道
            [_groupedSuppliers removeObject:supplier];
            break;
        default:
            break;
    }
    
    /// 命中用于展示的渠道
    AdvSupplier *target = _groupedSuppliers.firstObject;
    if (target.loadAdState == AdvanceSupplierLoadAdSuccess && !target.hited) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
        target.hited = YES;
        if ([_delegate respondsToSelector:@selector(advPolicyServiceFinishBiddingWithWinSupplier:)]) {
            [_delegate advPolicyServiceFinishBiddingWithWinSupplier:target];
        }
        [self reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:target error:nil];
    }
    
    // 该组渠道广告均返回失败，执行下一组渠道并发
    if (_groupedSuppliers.count == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
        [self loadMixedBiddingSuppliers];
    }
}

- (void)loadDataWithSupplierModel:(AdvPolicyModel *)model {
    if (!_arrayHeadBidding) {
        _arrayHeadBidding = [NSMutableArray array];
    }
    
    if (!_arrayWaterfall) {
        _arrayWaterfall = [NSMutableArray array];
    }

    self.model = model;
    self.model.setting.bidding_type = 0;
    self.supplierM = [self.model.suppliers mutableCopy];
    [self sortSupplierMByPriority];

    [self loadWaterfallSupplierAction];
    
}

// 开始执行策略
- (void)loadBiddingSupplier {
    if (_model == nil) {
        ADV_LEVEL_ERROR_LOG(@"策略请求失败");

        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }

        return;
    }
    
    
    // 如果用 bidding功能
    if (_model.setting.bidding_type == 1) {
        // 根据渠道标识 获取bidding的supplier去执行
        [self GMBiddingAction];

    } else {
        // head_bidding_group为参与bidding的渠道分组 parallel_group为普通瀑布流的分组
        // 目前聚合里所有的广告位adapter的逻辑都是有返回价格就取返回的价格, 没有返回的价格就取supplier里填写的价格
        // 综上, ios端所有的广告位都一样 本质不区分是否bidding  只是单纯的对价格进行比较并择机展现
        
        // 执行瀑布流的逻辑
        [self loadWaterfallSupplierAction];
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
    [waterfallPriority enumerateObjectsUsingBlock:^(NSNumber  *_Nonnull priority, NSUInteger idx, BOOL * _Nonnull stop) {
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
        // 执行bidding组的Supplier parallelSupplier
        AdvSupplier *biddingSupplier = [self getSupplierByPriority:[priority integerValue]];
        biddingSupplier.isParallel = YES;// 并发执行这些渠道
        biddingSupplier.positionType = AdvanceSdkSupplierTypeHeadBidding;///<==============
        [tempWaterfall addObject:biddingSupplier];
    }];
    
    [self.model.setting.headBiddingGroup removeAllObjects];

    // tempWaterfall = 0意味着所有parallelGroup 的渠道都没展现 这个时候 _incomeWaterfallCount应置为0, 避免卡住问题
    if (tempWaterfall.count > 0) {
        _incomeWaterfallCount = tempWaterfall.count + _arrayHeadBidding.count;
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
        if ([self.delegate respondsToSelector:@selector(advPolicyServiceStartBiddingWithSuppliers:)]) {
            [self.delegate advPolicyServiceStartBiddingWithSuppliers:tempWaterfall];
            
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
        [tempWaterfall enumerateObjectsUsingBlock:^(AdvSupplier  *_Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
            supplier.isParallel = YES;// 并发执行这些渠道
            [self notCPTLoadNextSuppluer:supplier error:nil];
        }];
        
    }

}


/// 非 CPT 执行下个渠道
- (void)notCPTLoadNextSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 非包天 选择渠道执行都失败
    if (supplier == nil || _supplierM.count <= 0) {
        // 抛异常
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadSupplier:error:)]) {
            [_delegate advPolicyServiceLoadSupplier:nil error:[AdvError errorWithCode:AdvErrorCode_114].toNSError];
        }
        return;
    }
    
    
    if (supplier.isParallel) {
        
    } else {
//        NSLog(@"展示队列优先级: %ld", (long)supplier.priority);
        if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]) {
            [_supplierM removeAllObjects];

        } else {
            [_supplierM removeObject:supplier];

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
        [self reportEventWithType:AdvanceSdkSupplierRepoLoaded supplier:supplier error:nil];
    }
    
    if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadSupplier:error:)]) {
        [_delegate advPolicyServiceLoadSupplier:supplier error:error];
    }
    ADV_LEVEL_INFO_LOG(@"执行过后执行的渠道:%@ 是否并行:%d 优先级:%ld name:%@", supplier, supplier.isParallel, (long)supplier.priority, supplier.name);

}

- (void)loadNextSupplierIfHas {
    // 执行非CPT渠道逻辑
    AdvSupplier *currentSupplier = _supplierM.lastObject;
    // 不管是不是并行渠道, 到了该执行的时候 必须要按照串行渠道的逻辑去执行
    currentSupplier.isParallel = NO;
    [self notCPTLoadNextSuppluer:currentSupplier error:nil];
}


// 开始下一组bidding
- (void)loadNextWaterfallSupplierIfHas {
//    NSLog(@"------------>>>>>>>");
    // 取当前bidding组里次优先胜出的广告
    AdvSupplier *currentSupplier = _arrayWaterfall.lastObject;
    currentSupplier.isParallel = NO;
    
    if (currentSupplier) {// 如果有 继续执行
//        NSLog(@"%s %@",__func__, currentSupplier.sdktag);
        [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    } else {
        [_arrayWaterfall removeAllObjects];
        _waterfallMinPrice = 0;
        [self loadWaterfallSupplierAction];
    }

    
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
    [_arrayWaterfall addObject:supplier];
    
    // 如果所有并发渠道都有结果返回了 则选择price高的渠道展示
//    NSLog(@"%@", self.arrayWaterfall.count);
//    NSLog(@"_incomeWaterfallCount = %ld  arrayWaterfall.count = %ld arrayHeadBidding.count = %ld", _incomeWaterfallCount, _arrayWaterfall.count, _arrayHeadBidding.count);
    if (_arrayWaterfall.count + _arrayHeadBidding.count == _incomeWaterfallCount) {
        [self _sortSuppliersByPrice:_arrayWaterfall];
    }
}

// 进入HeadBidding队列
- (void)inHeadBiddingQueueWithSupplier:(AdvSupplier *)supplier {
    if (!supplier) {
        return;
    }
    [_arrayHeadBidding addObject:supplier];
    
//    NSLog(@"===2=> %ld  %ld %ld", (long)_incomeWaterfallCount, self.arrayWaterfall.count, self.arrayHeadBidding.count);
    if (_arrayWaterfall.count + _arrayHeadBidding.count == _incomeWaterfallCount) {
        [self _sortSuppliersByPrice:_arrayWaterfall];
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
        if (_arrayWaterfall.count + _arrayHeadBidding.count == _incomeWaterfallCount) {
            [self _sortSuppliersByPrice:_arrayWaterfall];
        }
    }
}

// 检测时间戳, 如果bidding截止 那么就把当前返回广告的渠道
- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
//        NSLog(@"检测时间截止");
//        NSLog(@"===111=> %ld  %ld %ld", (long)_incomeWaterfallCount, self.arrayWaterfall.count, self.arrayHeadBidding.count);
        [self _sortSuppliersByPrice:_arrayWaterfall];
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
    NSMutableArray *tempBidding = [_arrayHeadBidding mutableCopy];
    
//    NSLog(@"suppliers = %@",suppliers);
//    NSLog(@"arrayHeadBidding = %@",self.arrayHeadBidding);

    NSMutableArray *tempSaveArr = [NSMutableArray array];
    [tempBidding enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSLog(@"=1=> %ld  %ld", obj.supplierPrice, _waterfallMinPrice);
        NSInteger obj_price = (obj.supplierPrice > 0) ? obj.supplierPrice : obj.sdk_price;
        if (obj_price >= _waterfallMinPrice) {
            [tempSaveArr addObject:obj];
        }
    }];
    
    [suppliers addObjectsFromArray:tempSaveArr];
    
    [_arrayHeadBidding removeObjectsInArray:tempSaveArr];

//    NSLog(@"suppliers = %@",suppliers);
//    NSLog(@"arrayHeadBidding = %@",self.arrayHeadBidding);

//     价格由低到高排序
//    NSLog(@"------1111111-> %@  %ld %ld", suppliers[0].sdktag, (long)obj11.supplierPrice, (long)obj11.priority);
    [suppliers sortWithOptions:NSSortStable usingComparator:^NSComparisonResult(id _Nonnull obj1, id _Nonnull obj2) {
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
    
    // 取价格最高的渠道执行
    AdvSupplier *currentSupplier = suppliers.lastObject;
    currentSupplier.isParallel = NO;
    currentSupplier.positionType = AdvanceSdkSupplierTypeWaterfall;
    // bidding结束
    if ([self.delegate respondsToSelector:@selector(advPolicyServiceFinishBiddingWithWinSupplier:)]) {
        [self.delegate advPolicyServiceFinishBiddingWithWinSupplier:currentSupplier];
    }
    
    // 执行的都从 arrayWaterfall里面删除
    if (_arrayWaterfall) {
        if ([_arrayWaterfall containsObject:currentSupplier]) {
            [_arrayWaterfall removeObject:currentSupplier];
        }
    }

//    NSLog(@"%s %@ %ld",__func__, currentSupplier.sdktag, currentSupplier.sdk_price);
    [self notCPTLoadNextSuppluer:currentSupplier error:nil];

}


- (void)loadNextSupplier {
    if (_model == nil) {
        ADV_LEVEL_ERROR_LOG(@"策略请求失败");
        
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_102].toNSError];
        }
        return;
    }
    
    // 非包天 model无渠道信息
    if (_model.suppliers.count <= 0) {
        
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_116].toNSError];
        }
        
        return;
    }
    

    [self sortSupplierMByPriority];
    AdvSupplier *currentSupplier = _supplierM.lastObject;
    currentSupplier.isParallel = NO;
    currentSupplier.positionType = AdvanceSdkSupplierTypeWaterfall;
    // bidding结束
    if ([self.delegate respondsToSelector:@selector(advPolicyServiceFinishBiddingWithWinSupplier:)]) {
        [self.delegate advPolicyServiceFinishBiddingWithWinSupplier:currentSupplier];
    }

    
    //         NSLog(@"%s %@", __func__, currentSupplier.sdktag);
    [self notCPTLoadNextSuppluer:currentSupplier error:nil];
    
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


#pragma mark - NetWork
/// 拉取实时策略信息
- (void)fetchPolicyData {
    NSMutableDictionary *deviceInfo = [[AdvDeviceInfoUtil sharedInstance] getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    
    if (self.ext) {
        
        // 如果是缓存渠道 请求的时候要标记一下
//        if (_isLoadLocalSupplier) {
//            [self.ext setValue:@"1" forKey:@"cache_effect"];
//        }
        
        [deviceInfo setValue:self.ext forKey:@"ext"];
    }
    
    ADV_LEVEL_INFO_LOG(@"%@", [self jsonStringCompactFormatForDictionary:deviceInfo]);
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:self.fetchTime];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    
    self.tkUploadTool.serverTime = [[NSDate date] timeIntervalSince1970]*1000;

    
    ADV_LEVEL_INFO_LOG(@"开始请求时间戳: %f", [[NSDate date] timeIntervalSince1970]);
    
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ADV_LEVEL_INFO_LOG(@"请求完成时间戳: %f", [[NSDate date] timeIntervalSince1970]);
            [self handleResultData:data error:error];
        });
        
    }];
    [dataTask resume];
}

/// 处理返回的数据
- (void)handleResultData:(NSData * )data error:(NSError *)error {
    // Error
    if (error) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_101 obj:error].toNSError];
        }
        return;
    }
    
    // No Result
    if (!data) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_102 obj:error].toNSError];
        }
        return;
    }
    
    AdvPolicyModel *a_model = [AdvPolicyModel adv_modelWithJSON:data];
    ADV_LEVEL_INFO_LOG(@"[JSON]%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
    // Parse Error
    if (!a_model) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_103].toNSError];
        }
        return;
    }
    
    // Code not 200
    if (a_model.code != 200) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_104 obj:error].toNSError];
        }
        return;
    }
    
    self.model = a_model;
    
    // Success Callback
    if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadSuccessWithModel:)]) {
        [_delegate advPolicyServiceLoadSuccessWithModel:self.model];
    }
    
    // 执行SDK策略
    [self executeSDKPolicy];
    
    
    // success
//    a_model.advMediaId = self.mediaId;
//    a_model.advAdspotId = self.adspotId;
    
//    if (!saveOnly) {
//        self.model = a_model;
//        _supplierM = [_model.suppliers mutableCopy];
//        [self sortSupplierMByPriority];
//
//        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadSuccessWithModel:)]) {
//            [_delegate advPolicyServiceLoadSuccessWithModel:self.model];
//        }
//
//        // 现在全都走新逻辑
//        [self loadBiddingSupplier];
//    }
}

- (NSString *)jsonStringCompactFormatForDictionary:(NSDictionary *)dicJson {

    if (![dicJson isKindOfClass:[NSDictionary class]] || ![NSJSONSerialization isValidJSONObject:dicJson]) {

        return nil;

    }
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicJson options:0 error:nil];

    NSString *strJson = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];

    return strJson;

}

- (void)cancelDataTask {
    if (_dataTask) {
        [_dataTask cancel];
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
    }
}

// MARK: ======================= 上报 =======================
- (void)reportEventWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(nullable NSError *)error{
    NSArray<NSString *> *uploadArr = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadArr = [self.tkUploadTool loadedtkUrlWithArr:supplier.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadArr =  supplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceed) {

        uploadArr =  [self.tkUploadTool succeedtkUrlWithArr:supplier.succeedtk price:(supplier.supplierPrice == 0) ? supplier.sdk_price : supplier.supplierPrice];
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadArr =  [self.tkUploadTool imptkUrlWithArr:supplier.imptk price:(supplier.supplierPrice == 0) ? supplier.sdk_price : supplier.supplierPrice];
    } else if (repoType == AdvanceSdkSupplierRepoFailed) {
        
        
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

- (void)setModel:(AdvPolicyModel *)model {
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
    [self cancelDataTask];
    _tkUploadTool = nil;
    
    [_arrayHeadBidding removeAllObjects];
    _arrayHeadBidding = nil;
    
    [_arrayWaterfall removeAllObjects];
    _arrayWaterfall = nil;

    [_supplierM removeAllObjects];
    _supplierM = nil;
    _model = nil;

}
@end
