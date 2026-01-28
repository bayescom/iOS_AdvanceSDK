//
//  AdvanceBanner.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceBanner;
@protocol AdvanceBannerDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onBannerAdDidLoad:(AdvanceBanner *)bannerAd;

/// 广告加载失败回调
-(void)onBannerAdFailToLoad:(AdvanceBanner *)bannerAd error:(NSError *)error;

/// 广告曝光回调
-(void)onBannerAdExposured:(AdvanceBanner *)bannerAd;

/// 广告展示失败回调
-(void)onBannerAdFailToPresent:(AdvanceBanner *)bannerAd error:(NSError *)error;

/// 广告点击回调
- (void)onBannerAdClicked:(AdvanceBanner *)bannerAd;

/// 广告关闭回调
- (void)onBannerAdClosed:(AdvanceBanner *)bannerAd;

@end

@interface AdvanceBanner : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceBannerDelegate> delegate;

/// 广告位尺寸
@property (nonatomic, assign) CGSize adSize;

/// 用于广告跳转的视图控制器
@property (nonatomic, weak) UIViewController *viewController;

/// banner广告视图
@property(nonatomic, strong, readonly) UIView *bannerView;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;


/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceBannerDelegate>)delegate;

/// 加载广告
- (void)loadAd;

@end

NS_ASSUME_NONNULL_END
