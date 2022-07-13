//
//  TXAdSplashTemplateConfig.h
//  TanxSDK
//
//  Created by guqiu on 2021/12/28.
//  Copyright © 2021 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdSplashTemplateConfig : NSObject

/// 跳转按钮颜色
@property (nonatomic, strong) UIColor *jumpTitleColor;

/// 跳转按钮字号大小
@property (nonatomic, strong) UIFont *jumpTitleFont;

///最大倒计时
@property (nonatomic, assign) NSInteger maxCountDown;




@end

NS_ASSUME_NONNULL_END
