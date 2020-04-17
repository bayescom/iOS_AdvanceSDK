//
//  MercuryNativeExpressAdView.h
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryEnumHeader.h"

@class BYImp;
@class MercuryNativeExpressAd;

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeExpressAdView : UIView

/// 控制器
@property (nonatomic, weak) UIViewController *controller;

/// 是否渲染完整
@property (nonatomic, assign, readonly) BOOL isReady;

/// 显示模式
@property (nonatomic, assign) MercuryNativeExpressAdSizeMode adSizeMode;

/// 自动播放时，是否静音。默认 NO。
@property (nonatomic, assign) BOOL videoMuted;

/// 按照 MercuryNativeExpressAd.renderSize 渲染广告
- (void)render;

@end

NS_ASSUME_NONNULL_END
