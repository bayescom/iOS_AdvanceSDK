//
//  TXAdFeedTemplateConfig.h
//  TanxSDK
//
//  Created by guqiu on 2022/1/8.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXAdShowMode) {
    TXAdShowModeNature = 0,     //默认显示自然模式
    TXAdShowModeDark,       //暗黑模式
};

@interface TXAdFeedTemplateConfig : NSObject

/// 左右padding
@property (nonatomic, assign) CGFloat horizontalPadding;

/// 上下padding，暂时无用
@property (nonatomic, assign) CGFloat verticalPadding;

/// 图片圆角大小
@property (nonatomic, assign) CGFloat picCorner;

/// 暗黑模式/正常模式
@property (nonatomic, assign) TXAdShowMode showModeDefine;

/// 信息流卡片背景颜色
@property (nonatomic, strong) UIColor *cardBgColor;

/// 自定义主标题颜色
@property (nonatomic, strong) UIColor *mainTitleColor;

/// 自定义主标题字号大小
@property (nonatomic, strong) UIFont *mainTitleFont;


@end

NS_ASSUME_NONNULL_END
