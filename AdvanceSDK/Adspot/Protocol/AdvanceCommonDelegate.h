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

/// 广告请求失败
- (void)advanceFailedWithError:(NSError *)error;

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId;
@end

#endif /* AdvanceBaseDelegate_h */
