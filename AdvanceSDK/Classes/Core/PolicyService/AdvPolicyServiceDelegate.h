//
//  AdvPolicyServiceDelegate.h
//
//  Created by guangyao on 2023/07/24.
//

@class AdvPolicyModel;
@class AdvSupplier;
@class AdvBidWinLossResult;

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
/// @param bidResult 二价结果 （单位：分）
- (void)policyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult *_Nonnull)bidResult;

/// Bidding失败
/// @param supplier 参竞的渠道
/// @param bidResult 一价结果 （单位：分）
- (void)policyServiceBidFailedWithBiddingSupplier:(AdvSupplier *_Nonnull)supplier bidResult:(AdvBidWinLossResult *_Nonnull)bidResult;

/// 所有Bidding渠道返回广告失败
/// @param error 错误信息
- (void)policyServiceAllAdnLoadAdFailedWithError:(NSError *_Nullable)error;

@end
