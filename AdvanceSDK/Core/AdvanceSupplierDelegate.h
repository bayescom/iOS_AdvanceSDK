//
//  AdvanceSupplierDelegate.h
//  Demo
//
//  Created by CherryKing on 2020/11/25.
//

#ifndef AdvanceSupplierDelegate_h
#define AdvanceSupplierDelegate_h

@class AdvSupplierModel;
@class AdvSupplier;
@protocol AdvanceSupplierDelegate <NSObject>

@optional

/// 加载策略Model成功
- (void)advanceBaseAdapterLoadSuccess:(nonnull AdvSupplierModel *)model;

/// 加载策略Model失败
- (void)advanceBaseAdapterLoadError:(nullable NSError *)error;


/// 返回下一个渠道的参数
/// @param supplier 被加载的渠道
/// @param error 异常信息
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error;

/// 开始bidding
/// @param suppliers 参加bidding的渠道
- (void)advanceBaseAdapterBiddingAction:(NSMutableArray <AdvSupplier *> *_Nullable)suppliers;

/// 结束bidding
/// @param supplier 竞胜渠道
- (void)advanceBaseAdapterBiddingEndWithWinSupplier:(AdvSupplier *_Nonnull)supplier;

/// bidding失败(即规定时间内,所有bidding广告为 都没有返回广告)
- (void)advBaseAdapterBiddingFailed;

@end

#endif /* AdvanceSupplierDelegate_h */
