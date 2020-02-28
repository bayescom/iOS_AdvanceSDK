//
//  MercuryInterstitialAd.h
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class MercuryInterstitialAd;

@protocol MercuryInterstitialAdDelegate <NSObject>
@optional

/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)mercury_interstitialSuccess;

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)mercury_interstitialFailError:(NSError *)error;

/// 插屏广告将要曝光回调，插屏广告即将曝光回调该函数
- (void)mercury_interstitialWillPresentScreen;

/// 插屏广告视图曝光成功回调，插屏广告曝光成功回调该函数
- (void)mercury_interstitialDidPresentScreen;

/// 插屏广告视图曝光失败回调，插屏广告曝光失败回调该函数
- (void)mercury_interstitialFailToPresent;

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)mercury_interstitialDidDismissScreen;

/// 插屏广告曝光回调
- (void)mercury_interstitialWillExposure;

/// 插屏广告点击回调
- (void)mercury_interstitialClicked;

@end

@interface MercuryInterstitialAd : NSObject

/// 代理对象
@property (nonatomic, weak) id<MercuryInterstitialAdDelegate> delegate;

/// 插屏广告是否加载完成
@property (nonatomic, assign, readonly) BOOL isAdValid;


/// 初始方法
/// @param adspotId 广告Id
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 初始方法
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryInterstitialAdDelegate> _Nullable)delegate;

/**
 *  广告发起请求方法
 *  详解：[必选]发起拉取广告请求
 */
- (void)loadAd;

/**
 *  广告曝光方法
 *  详解：[必选]发起曝光广告请求, 必须传入用于显示插播广告的UIViewController
 */
- (void)presentAdFromViewController:(UIViewController *)fromViewController;

@end

NS_ASSUME_NONNULL_END
