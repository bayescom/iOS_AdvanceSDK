//
//  AdvPolicyService.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/8/28.
//

#import "AdvPolicyService.h"
#import "AdvError.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "NSArray+Adv.h"
#import "NSString+Adv.h"
#import "AdvConstantHeader.h"
#import "AdvParameterHandler.h"
#import "AdvApiService.h"

@interface AdvPolicyService ()

/// 策略模型
@property (nonatomic, strong) AdvPolicyModel *model;
/// 发起请求时间戳
@property (nonatomic, assign) NSTimeInterval loadTimestamp;
/// 各渠道的错误回调信息
@property (nonatomic, strong) NSMutableDictionary *errorInfo;

/// 已根据优先级排序的第一组parallel渠道
@property (nonatomic, strong) NSMutableArray <AdvSupplier *> *parallelSuppliers;
/// headbidding组渠道
@property (nonatomic, strong) NSMutableArray <AdvSupplier *> *biddingSuppliers;
/// 混合策略组渠道
@property (nonatomic, strong) NSMutableArray <AdvSupplier *> *mixedSuppliers;
/// bidding组中最高价渠道
@property (nonatomic, strong) AdvSupplier *bidTargetSupplier;

@end

@implementation AdvPolicyService

- (instancetype)init {
    if (self = [super init]) {
        _errorInfo = [NSMutableDictionary dictionary];
    }
    return self;
}

+ (instancetype)manager {
    AdvPolicyService *mgr = [[AdvPolicyService alloc] init];
    return mgr;
}

#pragma mark: - 获取实时策略数据
- (void)loadPolicyDataWithAdspotId:(NSString *)adspotId
                             reqId:(NSString *)reqId
                             extra:(nullable NSDictionary *)extra {
    
    NSDictionary *parameter = [AdvParameterHandler requestParameterWithSpotId:adspotId reqId:reqId extra:extra];
    self.loadTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    
    [AdvApiService loadPolicyDataWithParameters:parameter completion:^(AdvPolicyModel * _Nonnull model, NSError * _Nonnull error) {
        if (error) {
            if ([self.delegate respondsToSelector:@selector(policyServiceLoadFailedWithError:)]) {
                [self.delegate policyServiceLoadFailedWithError:error];
            }
            return;
        }
        
        self.model = model;
        /// 过滤掉在后台添加了广告源，但客户端未集成SDK的渠道
        self.model.suppliers = [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
            return [AdvSupplierLoader isSDKInstalledWithSupplierId:supplier.identifier];
        }].mutableCopy;
        /// 所有渠道SDK都未安装回调
        if (!self.model.suppliers.count) {
            if ([self.delegate respondsToSelector:@selector(policyServiceLoadFailedWithError:)]) {
                [self.delegate policyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_SupplierUninstalled].toNSError];
            }
            return;
        }
        self.model.setting.headBiddingGroup = [self.model.setting.headBiddingGroup adv_filter:^BOOL(NSNumber *priority) {
            return [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
                return supplier.priority == priority.integerValue;
            }].count;
        }].mutableCopy;
        self.model.setting.parallelGroup = [self.model.setting.parallelGroup adv_map:^id(NSArray *group) {
            return [group adv_filter:^BOOL(NSNumber *priority) {
                return [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
                    return supplier.priority == priority.integerValue;
                }].count;
            }];
        }].mutableCopy;
        self.model.setting.parallelGroup = [self.model.setting.parallelGroup adv_filter:^BOOL(NSArray *group) {
            return group.count;
        }].mutableCopy;
        
        // Success Callback
        if ([self.delegate respondsToSelector:@selector(policyServiceLoadSuccessWithModel:)]) {
            [self.delegate policyServiceLoadSuccessWithModel:self.model];
        }
        // 执行SDK策略
        [self executeSDKPolicy];
    }];
}

/// 执行SDK策略
- (void)executeSDKPolicy {
    if (_model.setting.bidding_type == 1) { // GroMore竞价
        //[self startGroMoreBidding];
    } else { // 传统瀑布流 + 头部竞价
        [self loadSuppliersConcurrently];
    }
}

/// 并发加载各个渠道SDK
- (void)loadSuppliersConcurrently {
    
    if (self.model.setting.headBiddingGroup.count == 0 && !_bidTargetSupplier) { /// 瀑布流模式，无headbidding渠道
        
        /// 策略组无数据说明所有的组加载广告全部没有成功（因为第一层执行完总会被remove掉）
        if (self.model.setting.parallelGroup.count == 0) {
            if ([_delegate respondsToSelector:@selector(policyServiceFailedBiddingWithError:description:)]) {
                [_delegate policyServiceFailedBiddingWithError:[AdvError errorWithCode:AdvErrorCode_AllLoadAdFailed].toNSError description:_errorInfo];
            }
            return;
        }
    }
    /// 取BiddingGroup组
    NSArray *biddingSuppliers = [self.model.setting.headBiddingGroup adv_map:^id(NSNumber *priority) {
        return [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
            return supplier.priority == priority.integerValue;
        }].firstObject;
    }];
    _biddingSuppliers = [biddingSuppliers mutableCopy];
    
    /// 取parallelGroup当前第一层策略组
    NSArray *firstGroupSuppliers = [self.model.setting.parallelGroup.firstObject adv_map:^id(NSNumber *priority) {
        return [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
            return supplier.priority == priority.integerValue;
        }].firstObject;
    }];
    _parallelSuppliers = [firstGroupSuppliers mutableCopy];
    
    /// 合并2个组，开始执行竞价策略的回调
    NSMutableArray *templeSuppliers = [NSMutableArray array];
    if (biddingSuppliers.count) {
        [templeSuppliers addObjectsFromArray:biddingSuppliers];
    }
    if (firstGroupSuppliers.count) {
        [templeSuppliers addObjectsFromArray:firstGroupSuppliers];
    }
    
    if ([_delegate respondsToSelector:@selector(policyServiceStartBiddingWithSuppliers:)]) {
        [_delegate policyServiceStartBiddingWithSuppliers:templeSuppliers];
    }
    /// 并发执行混合策略下队列中的广告请求
    [templeSuppliers enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
        [self reportAdDataWithEventType:AdvSupplierReportTKEventLoaded supplier:supplier error:nil];
        if ([_delegate respondsToSelector:@selector(policyServiceLoadAnySupplier:)]) {
            [_delegate policyServiceLoadAnySupplier:supplier];
        }
    }];
    
    /// 执行完后移除parallel组渠道，确保再次调用此函数时能获取到下一组渠道
    if (self.model.setting.parallelGroup.count) {
        [self.model.setting.parallelGroup removeObjectAtIndex:0];
    }
    /// 执行完后移除bidding组渠道，确保再次调用此函数时该组不再参与竞价
    if (self.model.setting.headBiddingGroup.count) {
        [self.model.setting.headBiddingGroup removeAllObjects];
    }
    /// 该组渠道加载广告超时监测
    [self performSelector:@selector(observeLoadAdTimeout) withObject:nil afterDelay:self.model.setting.parallel_timeout * 1.0 / 1000];
}

/// 超时监测
- (void)observeLoadAdTimeout {
    NSArray *timeoutParallelSuppliers = [_parallelSuppliers adv_filter:^BOOL(AdvSupplier *supplier) {
        return supplier.loadAdState == AdvSupplierLoadAdReady;
    }];
    /// check方法中对_parallelSuppliers进行了移除操作，所以创建超时数组避免边遍历边移除带来问题
    [timeoutParallelSuppliers enumerateObjectsUsingBlock:^(AdvSupplier *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkTargetWithResultfulSupplier:obj state:AdvSupplierLoadAdTimeout error:[AdvError errorWithCode:AdvErrorCode_SupplierTimeout].toNSError];
    }];
    NSArray *timeoutBiddingSuppliers = [_biddingSuppliers adv_filter:^BOOL(AdvSupplier *supplier) {
        return supplier.loadAdState == AdvSupplierLoadAdReady;
    }];
    [timeoutBiddingSuppliers enumerateObjectsUsingBlock:^(AdvSupplier *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkTargetWithResultfulSupplier:obj state:AdvSupplierLoadAdTimeout error:[AdvError errorWithCode:AdvErrorCode_SupplierTimeout].toNSError];
    }];
}

/// [Public func]检测是否命中用于展示的渠道
/// 由每个渠道SDK Callback返回结果时调用 或者 超时后调用 或者 SDK初始化失败时调用
/// - Parameters:
///   - supplier: loadAd后返回结果的某个渠道
///   - state: loadAd后返回结果状态
///   - error: 错误信息
- (void)checkTargetWithResultfulSupplier:(AdvSupplier *)supplier
                                   state:(AdvSupplierLoadAdState)state
                                   error:(NSError *)error {
    
    /// 监测超时的方法中已经执行了本方法，所以超时后渠道返回的数据直接丢弃
    if (supplier.loadAdState == AdvSupplierLoadAdTimeout) {
        return;
    }
    
    supplier.loadAdState = state;
    switch (state) {
        case AdvSupplierLoadAdSuccess:
            /// 上报渠道广告获取成功
            [self reportAdDataWithEventType:AdvSupplierReportTKEventSucceed supplier:supplier error:nil];
            break;
        case AdvSupplierLoadAdFailed:
        case AdvSupplierLoadAdTimeout:
            /// 移除失败和超时的渠道
            if (!supplier.is_head_bidding) {
                [_parallelSuppliers removeObject:supplier];
            } else {
                [_biddingSuppliers removeObject:supplier];
            }
            /// 上报渠道广告获取失败/超时
            [self reportAdDataWithEventType:AdvSupplierReportTKEventFailed supplier:supplier error:error];
            break;
        default:
            break;
    }
    
    /// biddingSuppliers元素为空 有2种可能
    /// 1：本身无headbidding渠道，即瀑布流策略
    /// 2：本身有headbidding渠道，但是组内渠道都执行失败了，此时也走瀑布流策略
    if (_biddingSuppliers.count == 0 && !_bidTargetSupplier) {
        
        /// 进入瀑布流竞价执行、选中流程
        [self enterWaterfallFlow];
        
    } else { /// 混合竞价模式（瀑布流 + 头部竞价）
        
        /// 检测bidding组是否全部返回了结果，失败或超时渠道此前已被删除
        if ([_biddingSuppliers adv_filter:^BOOL(AdvSupplier *supplier) {
            return supplier.loadAdState == AdvSupplierLoadAdReady;
        }].count) {
            return;
        }
        
        /// 此时bidding组全部返回了结果，且组内都是竞价成功的渠道
        if (!_bidTargetSupplier && _biddingSuppliers.count) {
            /// 对biddingSuppliers进行排序
            [self sortedForPriceWithSuppliers:_biddingSuppliers];
            /// 取出最高价渠道
            _bidTargetSupplier = _biddingSuppliers.firstObject;
        }
        
        /// 进入混合竞价（瀑布流 + 头部竞价）执行、选中流程
        [self enterWaterfallMixedHeadbiddingFlow];
    }
}

/// 进入瀑布流竞价执行、选中流程
- (void)enterWaterfallFlow {
    
    // 该parallel组渠道广告均返回失败，执行下一组渠道并发
    if (_parallelSuppliers.count == 0) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
        [self loadSuppliersConcurrently];
        return;
    }
    /// 命中用于展示的渠道并回调
    [self hitTheTargetWithSuppliers:_parallelSuppliers];
}

/// 进入混合竞价（瀑布流 + 头部竞价）执行、选中流程
- (void)enterWaterfallMixedHeadbiddingFlow {
    
    /// 如果当前的parallelSuppliers都返回失败，并且bidTarget 比下一组的最高价低 则需要开启下一组parallelGroup
    if (_parallelSuppliers.count == 0) {
        NSArray *nextGroupPriorities = self.model.setting.parallelGroup.firstObject;
        NSMutableArray <AdvSupplier *> *nextGroupSuppliers = [nextGroupPriorities adv_map:^id(NSNumber *priority) {
            return [self.model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
                return supplier.priority == priority.integerValue;
            }].firstObject;
        }].mutableCopy;
        
        [self sortedForPriceWithSuppliers:nextGroupSuppliers];
        if (nextGroupSuppliers.count > 0 && _bidTargetSupplier.sdk_price < nextGroupSuppliers.firstObject.sdk_price) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
            [self loadSuppliersConcurrently];
            return;
        }
    }
    
    /// 无需开启下一组parallelGroup时，直接产生最新的执行队列
    if (_bidTargetSupplier) {
        _mixedSuppliers = [NSMutableArray arrayWithObject:_bidTargetSupplier];
    }
    if (_parallelSuppliers.count) {
        [_mixedSuppliers addObjectsFromArray:_parallelSuppliers];
    }
    /// 对最新产生的执行队列按价格进行排序
    [self sortedForPriceWithSuppliers:_mixedSuppliers];
    /// 命中用于展示的渠道并回调
    [self hitTheTargetWithSuppliers:_mixedSuppliers];
}

/// 命中用于展示的渠道并回调
- (void)hitTheTargetWithSuppliers:(NSMutableArray <AdvSupplier *> *)suppliers {
    AdvSupplier *target = suppliers.firstObject;
    if (target.loadAdState == AdvSupplierLoadAdSuccess && !target.hited) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
        target.hited = YES;
        if ([_delegate respondsToSelector:@selector(policyServiceFinishBiddingWithWinSupplier:)]) {
            [_delegate policyServiceFinishBiddingWithWinSupplier:target];
        }
        /// 竞胜上报
        [self reportAdDataWithEventType:AdvSupplierReportTKEventBidWin supplier:target error:nil];
    }
}

/// 混合策略排序规则：1. 按价格排序 2. 价格一样按优先级排序
- (void)sortedForPriceWithSuppliers:(NSMutableArray <AdvSupplier *> *)suppliers {
    [suppliers sortUsingComparator:^NSComparisonResult(AdvSupplier *  _Nonnull obj1, AdvSupplier *  _Nonnull obj2) {
        if (obj1.sdk_price == obj2.sdk_price) {
            return [@(obj1.priority) compare:@(obj2.priority)];
        }
        return [@(obj2.sdk_price) compare:@(obj1.sdk_price)];
    }];
}

/// [Public func]设置渠道返回的竞价
- (void)setECPMIfNeeded:(NSInteger)eCPM supplier:(AdvSupplier *)supplier {
    if (supplier.is_head_bidding && eCPM > 0) {
        supplier.sdk_price = eCPM;
    }
}


#pragma mark: - 数据上报
- (void)reportAdDataWithEventType:(AdvSupplierReportTKEventType)eventType
                         supplier:(AdvSupplier *)supplier
                            error:(nullable NSError *)error {
    if (error) {// 收集渠道错误信息
        [self collectErrorInfoWithSupplier:supplier error:error];
    }
    [AdvApiService reportAdDataWithEventType:eventType supplier:supplier loadTimestamp:self.loadTimestamp error:error];
}

- (void)collectErrorInfoWithSupplier:(AdvSupplier *)supplier error:(NSError *)error {
    // key: 渠道名-渠道id
    NSString *key = [NSString stringWithFormat:@"sdkname:%@-id:%@",supplier.name, supplier.identifier];
    [_errorInfo adv_safeSetObject:error forKey:key];
}


#pragma mark: - server rewarded
- (void)verifyRewardVideo:(AdvRewardVideoModel *)rewardVideoModel
                 supplier:(AdvSupplier *)supplier
              placementId:(NSString *)placementId
               completion:(void(^)(AdvRewardCallbackInfo *rewardInfo, NSError *error))completion {
    
    NSInteger rewardAmount = rewardVideoModel.rewardAmount ?: self.model.server_reward.count;
    NSString *rewardName = rewardVideoModel.rewardName ?: self.model.server_reward.name;
    AdvRewardCallbackInfo *rewardInfo = [[AdvRewardCallbackInfo alloc] initWithSourceId:supplier.identifier rewardName:rewardName rewardAmount:rewardAmount];
    
    if (self.model.server_reward.url) { // 服务端回调验证
        NSDictionary *param = @{
            @"timestamp": @((long)[[NSDate date] timeIntervalSince1970] * 1000),
            @"user_id": [NSString adv_validString:rewardVideoModel.userId],
            @"extra": [NSString adv_validString:rewardVideoModel.extra],
            @"reward_amount": @(rewardAmount),
            @"reward_name": [NSString adv_validString:rewardName],
            @"trans_id": self.model.reqid,
            @"placement_id": [NSString adv_validString:placementId],
            @"adn_channel_id": [NSString adv_validString:supplier.identifier],
            @"adn_adspot_id": [NSString adv_validString:supplier.adspotid],
        };
        [AdvApiService verifyServerSideRewardedURL:self.model.server_reward.url parameters:param completion:^(NSError * _Nonnull error) {
            if (!error) {
                completion(rewardInfo, nil);
            } else {
                completion(nil, error);
            }
        }];
    } else { // 客户端回调
        completion(rewardInfo, nil);
    }
}

- (void)dealloc {

}

@end
