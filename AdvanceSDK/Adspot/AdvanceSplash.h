//
//  AdvanceSplash.h
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceBaseAdSpot.h"
#import "AdvSdkConfig.h"
#import "AdvanceSplashDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceSplash : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceSplashDelegate> delegate;

/// 是否需要展示Logo 默认: NO
@property (nonatomic, assign) BOOL showLogoRequire;

/// 广告Logo 当 showLogoRequire = YES时, 必须设置logoImage
@property(nonatomic, strong) UIImage *logoImage;

/// 广告网络(广点通,穿山甲,快手等)是否有广告返回
@property(nonatomic, assign, readonly) BOOL isLoadAdSucceed;

/// 请求广告超时时间, 默认5s
/// 如果该时间内没有广告返回, 则会结束本次广告加载,并触发错误回调
/// 如果使用bidding 功能 timeout时长必须要比 服务器下发的bidding等待时间要长 否则会严重影响变现效率
@property (nonatomic, assign) NSInteger timeout;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController;

/// 加载广告
- (void)loadAd;

/// 展示广告
/// - Parameter window: 传入viewController所在的window,  或者keyWindow
- (void)showInWindow:(UIWindow *)window;

@end

NS_ASSUME_NONNULL_END
