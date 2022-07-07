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

// 开始bidding
- (void)advanceBaseAdapterBiddingAction:(NSMutableArray <AdvSupplier *> *_Nullable)suppliers;

// bidding结束
- (void)advanceBaseAdapterBiddingEndWithWinSupplier:(AdvSupplier *_Nonnull)supplier;

@end

#endif /* AdvanceSupplierDelegate_h */
