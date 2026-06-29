//
//  AdvRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/11.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AdvRenderFeedAdViewCreator <NSObject>

@optional
/// 广告平台logo视图
- (UIView *)logoImageView;

/// logo大小
- (CGSize)logoSize;

/// 视频播放视图
- (UIView *)videoAdView;

/// 绑定数据
- (void)refreshData;

/// 在原生广告视图中注册可点击视图。
- (void)registerContainer:(UIView *)containerView
       withClickableViews:(NSArray<UIView *> *)clickableViews;

@end

