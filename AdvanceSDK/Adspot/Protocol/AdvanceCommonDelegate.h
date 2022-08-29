//
//  AdvanceCommonDelegate.h
//  Pods
//
//  Created by MS on 2021/1/16.
//

#ifndef AdvanceCommonDelegate_h
#define AdvanceCommonDelegate_h

// 策略相关的代理
@protocol AdvanceCommonDelegate <NSObject>

@optional

/// 策略请求成功
/// @param reqId 策略id
/// 若 reqId = bottom_default 则执行的是打底渠道
- (void)advanceOnAdReceived:(NSString *)reqId;


/// 策略请求失败
/// @param error 聚合SDK的错误
/// @param description 每个渠道的错误详情, 部分情况下为nil  key的命名规则: 渠道名-优先级
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description;

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId;


//// 开始bidding
//- (void)advanceBiddingAction;
//
//// bidding结束
- (void)advanceBiddingEndWithPrice:(NSInteger)price;



@end

#endif /* AdvanceBaseDelegate_h */
