//
//  AdvanceNativeExpress.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvNativeExpressAdObject.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceNativeExpress;
@protocol AdvanceNativeExpressDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onNativeExpressAdSuccessToLoad:(AdvanceNativeExpress *)nativeExpress;

/// 广告加载失败回调
- (void)onNativeExpressAdFailToLoad:(AdvanceNativeExpress *)nativeExpress error:(NSError *)error;

/// 模板广告渲染成功
- (void)onNativeExpressAdViewRenderSuccess:(AdvNativeExpressAdObject *)nativeAdObject;

/// 模板广告渲染失败
- (void)onNativeExpressAdViewRenderFail:(AdvNativeExpressAdObject *)nativeAdObject error:(NSError *)error;

/// 广告曝光回调
-(void)onNativeExpressAdViewExposured:(AdvNativeExpressAdObject *)nativeAdObject;

/// 广告点击回调
- (void)onNativeExpressAdViewClicked:(AdvNativeExpressAdObject *)nativeAdObject;

/// 广告关闭回调
- (void)onNativeExpressAdViewClosed:(AdvNativeExpressAdObject *)nativeAdObject;

@end

/// 模板渲染信息流广告
@interface AdvanceNativeExpress : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

/// 广告位尺寸
@property (nonatomic, assign) CGSize adSize;

/// 用于广告跳转的视图控制器
@property (nonatomic, weak) UIViewController *viewController;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceNativeExpressDelegate>)delegate;

/// 加载广告
- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
