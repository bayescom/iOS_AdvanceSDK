//
//  MercurySplashAd.h
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MercurySplashAd;

NS_ASSUME_NONNULL_BEGIN

@protocol MercurySplashAdDelegate <NSObject>
@optional

/// 开屏广告模型加载成功
/// @param splashAd 广告数据
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd;

/// 开屏广告成功曝光
/// @param splashAd 广告数据
- (void)mercury_splashAdSuccessPresentScreen:(MercurySplashAd *)splashAd;

/// 开屏广告曝光失败
/// @param error 异常返回
- (void)mercury_splashAdFailError:(nullable NSError *)error;

/// 应用进入后台时回调
/// @param splashAd 广告数据
- (void)mercury_splashAdApplicationWillEnterBackground:(MercurySplashAd *)splashAd;

/// 开屏广告曝光回调
/// @param splashAd 广告数据
- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd;

/// 开屏广告点击回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd;

/// 开屏广告将要关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdWillClosed:(MercurySplashAd *)splashAd;

/// 开屏广告关闭回调
/// @param splashAd 广告数据
- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd;

/// 开屏广告剩余时间回调
- (void)mercury_splashAdLifeTime:(NSUInteger)time;

@end

@interface MercurySplashAd : NSObject
/// 回调
@property (nonatomic, weak) id<MercurySplashAdDelegate> delegate;

/// 拉取广告超时时间，默认为3秒
/// Desc: 拉取广告超时时间，开发者调用 loadDataWithResultBlock 方法以后会立即曝光backgroundImage，然后在该超时时间内，如果广告拉取成功，则立马曝光开屏广告，否则放弃此次广告曝光机会。
@property (nonatomic, assign) NSInteger fetchDelay;

/// 广告占位图
@property (nonatomic, strong) UIImage *placeholderImage;
/// Logo广告
@property (nonatomic, strong) UIImage *logoImage;
/// 父视图 详解：[必选]需设置为显示广告的UIViewController
@property (nonatomic, weak) UIViewController *controller;

/// 构造方法
/// @param adspotId 广告Id
/// @param delegate 代理
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercurySplashAdDelegate> _Nullable)delegate;

/// 广告发起请求并曝光在controller上中(Splash广告只支持竖屏)
- (void)loadAdAndShow;

/// 广告发起请求并曝光在controller上中(Splash广告只支持竖屏) 支持自定义底部View
/// @param bottomView 自定义底部View
- (void)loadAdAndShowWithBottomView:(UIView * _Nullable)bottomView;

/// /// 广告发起请求并曝光在controller上中(Splash广告只支持竖屏) 支持自定义底部View 跳过按钮
/// @param bottomView 自定义底部View
/// @param skipView 自定义跳过按钮
- (void)loadAdAndShowWithBottomView:(UIView * _Nullable)bottomView skipView:(UIView * _Nullable)skipView;

@end

NS_ASSUME_NONNULL_END
