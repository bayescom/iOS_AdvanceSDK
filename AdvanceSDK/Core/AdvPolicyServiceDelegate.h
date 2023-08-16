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
- (void)advPolicyServiceLoadSuccessWithModel:(nonnull AdvPolicyModel *)model;

/// 策略服务加载失败
- (void)advPolicyServiceLoadFailedWithError:(nullable NSError *)error;

/// 加载下一个渠道对象
/// @param supplier 被加载的渠道
/// @param error 异常信息
- (void)advPolicyServiceLoadSupplier:(nullable AdvSupplier *)supplier
                               error:(nullable NSError *)error;

/// 开始Bidding
/// @param suppliers 参加Bidding的渠道
- (void)advPolicyServiceStartBiddingWithSuppliers:(NSMutableArray <AdvSupplier *> *_Nullable)suppliers;

/// 结束Bidding
/// @param supplier 竞胜渠道
- (void)advPolicyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier;

/// Bidding失败 (即规定时间内,所有bidding渠道 都没有返回广告)
- (void)advPolicyServiceFailedBiddingWithError:(nullable NSError *)error;

@end
