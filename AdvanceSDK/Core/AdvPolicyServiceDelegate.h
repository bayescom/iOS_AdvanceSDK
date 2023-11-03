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

/// 加载某一个渠道对象
/// @param supplier 被加载的渠道
- (void)advPolicyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier;

/// 开始Bidding
/// @param suppliers 参加Bidding的渠道
- (void)advPolicyServiceStartBiddingWithSuppliers:(NSArray <AdvSupplier *> *_Nullable)suppliers;

/// 结束Bidding
/// @param supplier 竞胜渠道
- (void)advPolicyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier;

/// Bidding失败 (超时时间内，所有Bidding渠道返回广告都失败)
/// @param error 聚合SDK的策略错误信息
/// @param description 每个渠道的错误描述，部分情况下为nil
- (void)advPolicyServiceFailedBiddingWithError:(NSError *_Nullable)error description:(NSDictionary *_Nullable)description;

/// 加载GroMoreSDK
- (void)advPolicyServiceLoadGroMoreSDKWithModel:(nullable AdvPolicyModel *)model;

@end
