//
//  AdvPolicyService.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/8/28.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyModel.h"
#import "AdvPolicyServiceDelegate.h"
#import "AdvRewardVideoModel.h"
#import "AdvRewardCallbackInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvPolicyServiceDelegate;

//MARK: 策略服务类（非单例）
@interface AdvPolicyService : NSObject

/// 策略服务代理对象
@property (nonatomic, weak) id<AdvPolicyServiceDelegate> delegate;

/// 策略管理对象
+ (instancetype)manager;

/// 实时加载策略数据
/// @param adspotId 广告位id
/// @param reqId 请求id
/// @param extra 自定义拓展字段
- (void)loadPolicyDataWithAdspotId:(NSString *)adspotId
                             reqId:(NSString *)reqId
                             extra:(nullable NSDictionary *)extra;

/// 设置渠道返回的竞价
/// @param eCPM 竞价金额
/// @param supplier 当前渠道
- (void)setECPMIfNeeded:(NSInteger)eCPM
               supplier:(AdvSupplier *)supplier;

/// 检测是否命中用于展示的渠道
/// 由每个渠道SDK Callback返回结果时调用 或者 超时后调用 或者 SDK初始化失败时调用
/// - Parameters:
///   - supplier: loadAd后返回结果的某个渠道
///   - state: loadAd后返回结果状态
///   - error: 错误信息
- (void)checkTargetWithResultfulSupplier:(AdvSupplier *)supplier
                                   state:(AdvSupplierLoadAdState)state
                                   error:(nullable NSError *)error;

/// TK监测数据上报
/// @param eventType 事件类型
/// @param supplier 渠道对象
/// @param error 错误信息
- (void)reportAdDataWithEventType:(AdvSupplierReportTKEventType)eventType
                         supplier:(AdvSupplier *)supplier
                            error:(nullable NSError *)error;

/// 验证激励视频奖励
- (void)verifyRewardVideo:(AdvRewardVideoModel *)rewardVideoModel
                 supplier:(AdvSupplier *)supplier
              placementId:(NSString *)placementId
               completion:(void(^)(AdvRewardCallbackInfo *rewardInfo, NSError *error))completion;

@end

NS_ASSUME_NONNULL_END
