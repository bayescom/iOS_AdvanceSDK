//
//  AdvanceBaseDelegate.h
//  Pods
//
//  Created by MS on 2020/12/9.
//

#ifndef AdvanceBaseDelegate_h
#define AdvanceBaseDelegate_h
#import "AdvanceFaildDelegate.h"
// 策略相关的代理
@protocol AdvanceBaseDelegate <AdvanceFaildDelegate>

@optional

/// 广告曝光成功
- (void)advanceExposured;

/// 广告点击回调
- (void)advanceClicked;

/// 广告数据请求成功后调用
- (void)advanceUnifiedViewDidLoad;

/// 广告关闭的回调
- (void)advanceDidClose;

@end

#endif /* AdvanceBaseDelegate_h */
