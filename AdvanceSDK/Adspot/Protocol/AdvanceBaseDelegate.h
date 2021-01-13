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

@end

#endif /* AdvanceBaseDelegate_h */
