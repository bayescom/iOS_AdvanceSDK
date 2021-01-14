//
//  AdvanceBaseDelegate.h
//  Pods
//
//  Created by MS on 2020/12/9.
//

#ifndef AdvanceBaseDelegate_h
#define AdvanceBaseDelegate_h
// 策略相关的代理
@protocol AdvanceBaseDelegate <NSObject>

@optional


/// 策略请求成功
/// @param reqId 策略id
/// 若 reqId = bottom_default 则执行的是打底渠道
- (void)advanceOnAdReceived:(NSString *)reqId;


/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error;

/// 广告曝光成功
- (void)advanceExposured;

/// 广告点击回调
- (void)advanceClicked;

/// 广告数据请求成功后调用
- (void)advanceUnifiedViewDidLoad;

/// 广告关闭的回调
- (void)advanceDidClose;

/// 广告请求失败
- (void)advanceFailedWithError:(NSError *)error;

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId;
@end

#endif /* AdvanceBaseDelegate_h */
