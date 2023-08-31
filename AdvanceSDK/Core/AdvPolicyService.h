//
//  AdvPolicyService.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/8/28.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"
#import "AdvPolicyServiceDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvPolicyServiceDelegate;

//MARK: 策略服务类（非单例）
@interface AdvPolicyService : NSObject

/// 网络请求超时时间（默认: 5秒）
@property (nonatomic, assign) NSTimeInterval fetchTime;

@property (nonatomic, weak) id<AdvPolicyServiceDelegate> delegate;

/// 数据管理对象
+ (instancetype)manager;

/**
 * 获取策略数据
 * 如果本地存在有效数据，直接加载本地数据
 * 数据不存在则网络获取数据
 * @param mediaId 媒体id
 * @param adspotId 广告位id
 * @param ext 自定义拓展字段
 */
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary *_Nonnull)ext;

/// 加载策略
- (void)loadDataWithSupplierModel:(AdvPolicyModel *)model;

/**
 * 加载下个渠道
 * 回调 advSupplierLoadSuppluer: error:
 */
- (void)loadNextSupplierIfHas;

/**
 * 加载下一层bidding
 * 回调 advSupplierLoadSuppluer: error:
 */
- (void)loadNextWaterfallSupplierIfHas;


/// 取消正在进行的策略请求
- (void)cancelDataTask;

/// 进入bidding队列
- (void)inWaterfallQueueWithSupplier:(AdvSupplier *)supplier;

// 进入HeadBidding队列
- (void)inHeadBiddingQueueWithSupplier:(AdvSupplier *)supplier;

// 接收失败的并发渠道
- (void)inParallelWithErrorSupplier:(AdvSupplier *)errorSupplier;


#pragma mark: - Refactor

/// 设置渠道返回的竞价
/// @param eCPM 竞价金额
/// @param supplier 当前渠道
- (void)setECPMIfNeeded:(NSInteger)eCPM supplier:(AdvSupplier *)supplier;

/// 检测是否命中用于展示的渠道
/// 由每个渠道SDK Callback返回结果时调用 或者 超时后调用
/// - Parameters:
///   - supplier: loadAd后返回结果的某个渠道
///   - state: loadAd后返回结果状态
- (void)checkTargetWithResultfulSupplier:(AdvSupplier *)supplier loadAdState:(AdvanceSupplierLoadAdState)state;

/// 数据上报
/// @param repoType 上报的类型
- (void)reportEventWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
