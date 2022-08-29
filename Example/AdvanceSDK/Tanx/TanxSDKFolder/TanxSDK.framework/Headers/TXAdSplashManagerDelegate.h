//
//  TXAdSplashManagerDelegate.h
//  TanxSDK
//
//  Created by guqiu on 2021/12/30.
//  Copyright © 2021 tanx.com. All rights reserved.
//

#ifndef TXAdSplashManagerDelegate_h
#define TXAdSplashManagerDelegate_h

@protocol TXAdSplashManagerDelegate <NSObject>

@required
///点击了跳转，或者触发了摇一摇跳转
///webUrl 如果非空，需要接入方实现H5跳转
- (void)onSplashClickWithWebUrl:(NSString *)webUrl;

@optional

/// 开屏开始展示
- (void)onSplashShow;

/// 开屏关闭
- (void)onSplashClose;


@end

#endif /* TXAdSplashManagerDelegate_h */
