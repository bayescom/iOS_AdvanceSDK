//
//  MercuryNativeExpressAd.h
//  Example
//
//  Created by CherryKing on 2019/12/13.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryEnumHeader.h"
#import "MercuryNativeExpressAdView.h"

//@class MercuryNativeExpressAdView;
@class MercuryNativeExpressAd;

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryNativeExpressAdDelegete <NSObject>

@optional
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(MercuryNativeExpressAd *)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views;

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error;

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView;

/// 原生模板视频广告 player 播放状态更新回调
- (void)mercury_nativeExpressAdView:(MercuryNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end

@interface MercuryNativeExpressAd : NSObject

/// 广告展示的宽高
@property (nonatomic, assign) CGSize renderSize;

/// 代理
@property (nonatomic, weak) id<MercuryNativeExpressAdDelegete> delegate;

/// 播放策略
@property (nonatomic, assign) MercuryVideoAutoPlayPolicy videoPlayPolicy;

/// 自动播放时，是否静音。默认 YES。
@property (nonatomic, assign) BOOL videoMuted;

/// 构造方法
/// @param adspotId adspotId
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId;

/// 加载广告
- (void)loadAdWithCount:(NSInteger)count;

@end

NS_ASSUME_NONNULL_END
