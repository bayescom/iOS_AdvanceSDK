//
//  AdvPolicyServiceDelegate.h
//
//  Created by guangyao on 2023/07/24.
//

@class AdvPolicyModel;
@class AdvSupplier;

@protocol AdvPolicyServiceDelegate <NSObject>

@optional

/// 策略服务加载成功
- (void)policyServiceLoadSuccessWithModel:(nonnull AdvPolicyModel *)model;

/// 策略服务加载失败
- (void)policyServiceLoadFailedWithError:(nullable NSError *)error;

/// 开始Bidding
/// @param suppliers 参加Bidding的渠道
- (void)policyServiceStartBiddingWithSuppliers:(NSArray <AdvSupplier *> *_Nullable)suppliers;

/// 加载某一个渠道对象
/// @param supplier 被加载的渠道
- (void)policyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier;

/// Bidding成功
/// @param supplier 竞胜渠道
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier;

/// Bidding失败 (超时时间内，所有Bidding渠道返回广告都失败)
/// @param error 聚合SDK的策略错误信息
/// @param description 每个渠道的错误描述，部分情况下为nil
- (void)policyServiceFailedBiddingWithError:(NSError *_Nullable)error description:(NSDictionary *_Nullable)description;

@end
