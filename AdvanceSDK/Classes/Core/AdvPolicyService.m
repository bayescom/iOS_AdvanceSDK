//
//  AdvPolicyService.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/8/28.
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

/// 策略模型
@property (nonatomic, strong) AdvPolicyModel *model;
/// 媒体id
@property (nonatomic, copy) NSString *mediaId;
/// 广告位id
@property (nonatomic, copy) NSString *adspotId;
/// 自定义拓展字段
@property (nonatomic, strong) NSDictionary *ext;

@property (nonatomic, strong) AdvUploadTKUtil *tkUploadTool;

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

/// 获取策略数据
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary * _Nonnull)ext {
    _mediaId = mediaId;
    _adspotId = adspotId;
    _ext = ext;
    /// 获取实时策略信息
    [self fetchPolicyData];
}

/// 执行SDK策略
- (void)executeSDKPolicy {
    if (_model.setting.bidding_type == 1) { // GroMore竞价
        [self startGroMoreBidding];
    } else { // 传统瀑布流 + 头部竞价
        [self loadSuppliersConcurrently];
    }
}

/// for gromore bidding
- (void)startGroMoreBidding {
    if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadGroMoreSDKWithModel:)]) {
        [_delegate advPolicyServiceLoadGroMoreSDKWithModel:self.model];
    }
    [self reportGroMoreEventWithType:AdvanceSdkSupplierRepoLoaded groMore:self.model.gro_more error:nil];
}

/// for gromore bidding
- (void)catchBidTargetWhenGroMoreBiddingWithPolicyModel:(nullable AdvPolicyModel *)model {
    self.model = model;
    [self loadSuppliersConcurrently];
}

/// 并发加载各个渠道SDK
- (void)loadSuppliersConcurrently {
    
    if (self.model.setting.headBiddingGroup.count == 0 && !_bidTargetSupplier) { /// 瀑布流模式，无headbidding渠道
        
        /// 策略组无数据说明所有的组加载广告全部没有成功（因为第一层执行完总会被remove掉）
        if (self.model.setting.parallelGroup.count == 0) {
            if ([_delegate respondsToSelector:@selector(advPolicyServiceFailedBiddingWithError:description:)]) {
                [_delegate advPolicyServiceFailedBiddingWithError:[AdvError errorWithCode:AdvErrorCode_106].toNSError description:_errorInfo];
            }
            return;
        }
    }
    /// 取BiddingGroup组
    NSArray *biddingSuppliers = [self.model.setting.headBiddingGroup map:^id(NSNumber *priority) {
        return [self.model.suppliers filter:^BOOL(AdvSupplier *supplier) {
            return supplier.priority == priority.integerValue;
        }].firstObject;
    }];
    _biddingSuppliers = [biddingSuppliers mutableCopy];
    
    /// 取parallelGroup当前第一层策略组
    NSArray *firstGroupSuppliers = [self.model.setting.parallelGroup.firstObject map:^id(NSNumber *priority) {
        return [self.model.suppliers filter:^BOOL(AdvSupplier *supplier) {
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
    if ([_delegate respondsToSelector:@selector(advPolicyServiceStartBiddingWithSuppliers:)]) {
        [_delegate advPolicyServiceStartBiddingWithSuppliers:templeSuppliers];
    }
    /// 并发执行混合策略下队列中的广告请求
    [templeSuppliers enumerateObjectsUsingBlock:^(AdvSupplier * _Nonnull supplier, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadAnySupplier:)]) {
            [_delegate advPolicyServiceLoadAnySupplier:supplier];
        }
        [self reportEventWithType:AdvanceSdkSupplierRepoLoaded supplier:supplier error:nil];
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
    ADVLog(@"开始加载各渠道");
}

/// 超时监测
- (void)observeLoadAdTimeout {
    NSArray *timeoutParallelSuppliers = [_parallelSuppliers filter:^BOOL(AdvSupplier *supplier) {
        return supplier.loadAdState == AdvanceSupplierLoadAdReady;
    }];
    /// check方法中对_parallelSuppliers进行了移除操作，所以创建超时数组避免边遍历边移除带来问题
    [timeoutParallelSuppliers enumerateObjectsUsingBlock:^(AdvSupplier *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkTargetWithResultfulSupplier:obj loadAdState:AdvanceSupplierLoadAdTimeout];
    }];
    NSArray *timeoutBiddingSuppliers = [_biddingSuppliers filter:^BOOL(AdvSupplier *supplier) {
        return supplier.loadAdState == AdvanceSupplierLoadAdReady;
    }];
    [timeoutBiddingSuppliers enumerateObjectsUsingBlock:^(AdvSupplier *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self checkTargetWithResultfulSupplier:obj loadAdState:AdvanceSupplierLoadAdTimeout];
    }];
}

/// [Public func]检测是否命中用于展示的渠道
/// 由每个渠道SDK Callback返回结果时调用 或者 超时后调用
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
            if (!supplier.is_head_bidding) {
                [_parallelSuppliers removeObject:supplier];
            } else {
                [_biddingSuppliers removeObject:supplier];
            }
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
        if ([_biddingSuppliers filter:^BOOL(AdvSupplier *supplier) {
            return supplier.loadAdState == AdvanceSupplierLoadAdReady;
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
        NSMutableArray <AdvSupplier *> *nextGroupSuppliers = [nextGroupPriorities map:^id(NSNumber *priority) {
            return [self.model.suppliers filter:^BOOL(AdvSupplier *supplier) {
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
    if (target.loadAdState == AdvanceSupplierLoadAdSuccess && !target.hited) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(observeLoadAdTimeout) object:nil];
        target.hited = YES;
        if ([_delegate respondsToSelector:@selector(advPolicyServiceFinishBiddingWithWinSupplier:)]) {
            [_delegate advPolicyServiceFinishBiddingWithWinSupplier:target];
        }
        /// 竞胜上报
        [self reportEventWithType:AdvanceSdkSupplierRepoBidWin supplier:target error:nil];
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

#pragma mark - NetWork
/// 拉取实时策略信息
- (void)fetchPolicyData {
    NSMutableDictionary *deviceInfo = [[AdvDeviceInfoUtil sharedInstance] getDeviceInfoWithMediaId:_mediaId adspotId:_adspotId];
    
    if (_ext) {
        [deviceInfo setValue:_ext forKey:@"ext"];
    }
    
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:deviceInfo options:NSJSONWritingPrettyPrinted error:&parseError];
    NSURL *url = [NSURL URLWithString:AdvanceSdkRequestUrl];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:5];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = jsonData;
    request.HTTPMethod = @"POST";
    NSURLSession *sharedSession = [NSURLSession sharedSession];
    
    
    self.tkUploadTool.requestTime = [[NSDate date] timeIntervalSince1970] * 1000;
    
    
    ADVLog(@"开始请求时间戳: %f", [[NSDate date] timeIntervalSince1970]);
    
    NSURLSessionDataTask *dataTask = [sharedSession dataTaskWithRequest:request
                                                      completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            ADVLog(@"请求完成时间戳: %f", [[NSDate date] timeIntervalSince1970]);
            [self handleResultData:data error:error];
        });
        
    }];
    [dataTask resume];
}

/// 处理返回的数据
- (void)handleResultData:(NSData *)data error:(NSError *)error {
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
    ADVLog(@"[JSON]%@", [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil]);
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
    
    // no suppliers
    if (a_model.suppliers.count == 0) {
        if ([_delegate respondsToSelector:@selector(advPolicyServiceLoadFailedWithError:)]) {
            [_delegate advPolicyServiceLoadFailedWithError:[AdvError errorWithCode:AdvErrorCode_105].toNSError];
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
}

// MARK: ======================= 数据上报 =======================
- (void)reportEventWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(nullable NSError *)error{
    /// 收集渠道错误信息
    if (error) {
        [self collectSupplierErrorInfomation:supplier error:error];
    }
    
    NSArray<NSString *> *uploadUrls = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadUrls = [self.tkUploadTool loadedtkUrlWithArr:supplier.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadUrls = supplier.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceed) {
        uploadUrls =  [self.tkUploadTool succeedtkUrlWithArr:supplier.succeedtk price:supplier.sdk_price];
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadUrls =  [self.tkUploadTool imptkUrlWithArr:supplier.imptk price:supplier.sdk_price];
    } else if (repoType == AdvanceSdkSupplierRepoFailed) {
        uploadUrls =  [self.tkUploadTool failedtkUrlWithArr:supplier.failedtk error:error];
    } else if (repoType == AdvanceSdkSupplierRepoBidWin) {
        uploadUrls =  [self.tkUploadTool imptkUrlWithArr:supplier.wintk price:supplier.sdk_price];
    }
    
    if (!uploadUrls.count) {
        return;
    }
    // 执行上报请求
    [self.tkUploadTool reportWithUploadUrls:uploadUrls];
    ADVLog(@"%@ = 上报(impid: %@)", ADVStringFromNAdvanceSdkSupplierRepoType(repoType), supplier.name);
}

- (void)collectSupplierErrorInfomation:(AdvSupplier *)supplier error:(NSError *)error; {
    // key: 渠道名-渠道id
    NSString *key = [NSString stringWithFormat:@"sdkname:%@-id:%@",supplier.name, supplier.identifier];
    [_errorInfo setObject:error forKey:key];
}

#pragma mark: - for GroMore
- (void)reportGroMoreEventWithType:(AdvanceSdkSupplierRepoType)repoType groMore:(Gro_more *)groMore error:(nullable NSError *)error {
    /// 收集GroMore错误信息
    if (error) {
        [self collectGroMoreErrorInfomation:error];
    }
    
    NSArray<NSString *> *uploadUrls = nil;
    /// 按照类型判断上报地址
    if (repoType == AdvanceSdkSupplierRepoLoaded) {
        uploadUrls = [self.tkUploadTool loadedtkUrlWithArr:groMore.gmtk.loadedtk];
    } else if (repoType == AdvanceSdkSupplierRepoClicked) {
        uploadUrls = groMore.gmtk.clicktk;
    } else if (repoType == AdvanceSdkSupplierRepoSucceed) {
        uploadUrls =  [self.tkUploadTool succeedtkUrlWithArr:groMore.gmtk.succeedtk price:groMore.gromore_params.bidPrice];
    } else if (repoType == AdvanceSdkSupplierRepoImped) {
        uploadUrls =  [self.tkUploadTool imptkUrlWithArr:groMore.gmtk.imptk price:groMore.gromore_params.bidPrice];
    } else if (repoType == AdvanceSdkSupplierRepoFailed) {
        uploadUrls =  [self.tkUploadTool failedtkUrlWithArr:groMore.gmtk.failedtk error:error];
    } else if (repoType == AdvanceSdkSupplierRepoBidWin) {
        uploadUrls =  [self.tkUploadTool imptkUrlWithArr:groMore.gmtk.biddingtk price:groMore.gromore_params.bidPrice];
    }
    
    if (!uploadUrls.count) {
        return;
    }
    // 执行上报请求
    [self.tkUploadTool reportWithUploadUrls:uploadUrls];
}

- (void)collectGroMoreErrorInfomation:(NSError *)error; {
    [_errorInfo setObject:error forKey:@"gromoresdk"];
}

- (AdvUploadTKUtil *)tkUploadTool {
    if (!_tkUploadTool) {
        _tkUploadTool = [AdvUploadTKUtil new];
    }
    return _tkUploadTool;
}

- (void)dealloc {
    ADVLog(@"%s %@", __func__, self);
}

@end
