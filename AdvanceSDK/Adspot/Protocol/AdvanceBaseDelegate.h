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
/// 策略请求失败
- (void)advanceOnAdNotFilled:(NSError *)error;

@end

#endif /* AdvanceBaseDelegate_h */
