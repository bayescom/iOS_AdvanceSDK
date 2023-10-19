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

/// 策略服务代理对象
@property (nonatomic, weak) id<AdvPolicyServiceDelegate> delegate;
/// 各渠道的错误回调信息
@property (nonatomic, strong) NSMutableDictionary *errorInfo;

/// 数据管理对象
+ (instancetype)manager;

/// 实时加载策略数据
/// @param mediaId 媒体id
/// @param adspotId 广告位id
/// @param ext 自定义拓展字段
- (void)loadDataWithMediaId:(NSString *)mediaId
                   adspotId:(NSString *)adspotId
                  customExt:(NSDictionary *_Nonnull)ext;

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

/// gromore bidding时获取Advance广告位的竞胜渠道
- (void)catchBidTargetWhenGroMoreBiddingWithPolicyModel:(nullable AdvPolicyModel *)model;

/// gromore数据上报
- (void)reportGroMoreEventWithType:(AdvanceSdkSupplierRepoType)repoType groMore:(Gro_more *)groMore error:(nullable NSError *)error;

@end

NS_ASSUME_NONNULL_END
