//
//  AdvRenderFeedAdView.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvRenderFeedAdView : UIView

/// 广告平台logo视图
@property (nonatomic, strong, readonly) UIView *logoImageView;

/// logo大小
@property (nonatomic, assign, readonly) CGSize logoSize;

/// 视频播放视图
@property (nonatomic, strong, readonly) UIView *videoAdView;

/// 刷新广告数据
- (void)refreshData;

/// 绑定可点击视图
- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews;


@end

NS_ASSUME_NONNULL_END
