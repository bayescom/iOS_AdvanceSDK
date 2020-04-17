//
//  MercuryNativeAdView.h
//  Example
//
//  Created by CherryKing on 2019/12/25.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MercuryEnumHeader.h"
#import "MercuryMediaView.h"

@class MercuryNativeAd;
@class MercuryNativeAdDataModel;

NS_ASSUME_NONNULL_BEGIN

@class MercuryNativeAdView;

@protocol MercuryNativeAdViewDelegate <NSObject>

@optional

/// 广告曝光回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewWillExpose:(MercuryNativeAdView *)nativeAdView;

/// 广告点击回调
/// @param nativeAdView MercuryNativeAdView 实例
- (void)mercury_nativeAdViewDidClick:(MercuryNativeAdView *)nativeAdView;

/// 视频广告播放状态更改回调
/// @param nativeAdView MercuryNativeAdView 实例
/// @param status 视频广告播放状态
- (void)mercury_nativeAdView:(MercuryNativeAdView *)nativeAdView playerStatusChanged:(MercuryMediaPlayerStatus)status;

@end

@interface MercuryNativeAdView : UIView

/// 绑定的数据对象
@property (nonatomic, strong, readonly) MercuryNativeAdDataModel *dataModel;

/// 绑定的广告对象
@property (nonatomic, strong, readonly) MercuryNativeAd *nativeAd;

/// 视频广告的媒体View，绑定数据对象后自动生成，可自定义布局
@property (nonatomic, strong, readonly) MercuryMediaView *mediaView;

/// 广告 View 时间回调对象
@property (nonatomic, weak) id<MercuryNativeAdViewDelegate> delegate;

/// 开发者需传入用来弹出目标页的ViewController，一般为当前ViewController
@property (nonatomic, weak) UIViewController *controller;

/**
 注意：regist后如果dataModel是视频广告，会产生mediaView对象
 @param nativeAd 自渲染广告对象 [必传]
 @param dataModel 数据对象 [必传]
 @param clickableViews 可点击的视图数组，此数组内的广告元素才可以响应广告对应的点击事件
 */
- (void)registerNativeAd:(MercuryNativeAd *)nativeAd
              dataObject:(MercuryNativeAdDataModel *)dataModel
          clickableViews:(NSArray<UIView *> *)clickableViews;

/**
 注册可点击的callToAction视图的方法
 建议开发者使用MercuryNativeAdDataObject中的callToAction字段来创建视图，并取代自定义的下载或打开等button,
 调用此方法之前必须先调用registerDataObject:clickableViews
 @param callToActionView CTA视图, 系统自动处理点击事件
 */
- (void)registerClickableCallToActionView:(UIView *)callToActionView;

/**
 注销数据对象，在 tableView、collectionView 等场景需要复用 MercuryNativeAdView 时，
 需要在合适的时机，例如 cell 的 prepareForReuse 方法内执行 unregisterDataObject 方法，
 将广告对象与 MercuryNativeAdView 解绑，具体可参考示例 demo 的 UnifiedNativeAdBaseTableViewCell 类
 */
- (void)unregisterDataObject;

@end





NS_ASSUME_NONNULL_END
