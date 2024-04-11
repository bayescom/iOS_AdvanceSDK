//
//  AdvanceSplash.h
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSplash : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

/// 是否需要展示Logo 默认: NO
@property (nonatomic, assign) BOOL showLogoRequire;

/// 广告Logo 当 showLogoRequire = YES时, 必须设置logoImage
@property(nonatomic, strong) UIImage *logoImage;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param ext 自定义拓展参数
/// @param viewController 广告加载容器 （建议传入当前控制器，广告需要提前加载可传nil）
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(nullable UIViewController *)viewController;

/// 加载广告
- (void)loadAd;

/// 展示广告
/// - Parameter window: 传入viewController所在的window,  或者keyWindow
- (void)showInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
