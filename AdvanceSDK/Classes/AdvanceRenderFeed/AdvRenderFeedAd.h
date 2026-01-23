//
//  AdvRenderFeedAd.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvRenderFeedAdElement.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvRenderFeedAd : NSObject

/// 自渲染信息流广告素材
@property (nonatomic, strong) AdvRenderFeedAdElement *feedAdElement;

/// 自渲染信息流展示容器
@property (nonatomic, strong) UIView *feedAdView;

/// 广告平台logo视图
@property (nonatomic, strong, readonly) UIView *logoImageView;

/// logo大小
@property (nonatomic, assign, readonly) CGSize logoSize;

/// 视频播放视图
@property (nonatomic, strong, readonly) UIView *videoAdView;


- (instancetype)initWithFeedAdView:(UIView *)feedAdView feedAdElement:(AdvRenderFeedAdElement *)feedAdElement;

/// 绑定可点击、可关闭的视图
- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView;

@end

NS_ASSUME_NONNULL_END
