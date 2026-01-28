//
//  AdvanceInterstitial.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceInterstitial;
@protocol AdvanceInterstitialDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onInterstitialAdDidLoad:(AdvanceInterstitial *)interstitialAd;

/// 广告加载失败回调
-(void)onInterstitialAdFailToLoad:(AdvanceInterstitial *)interstitialAd error:(NSError *)error;

/// 广告曝光回调
-(void)onInterstitialAdExposured:(AdvanceInterstitial *)interstitialAd;

/// 广告展示失败回调
-(void)onInterstitialAdFailToPresent:(AdvanceInterstitial *)interstitialAd error:(NSError *)error;

/// 广告点击回调
- (void)onInterstitialAdClicked:(AdvanceInterstitial *)interstitialAd;

/// 广告关闭回调
- (void)onInterstitialAdClosed:(AdvanceInterstitial *)interstitialAd;

@end

@interface AdvanceInterstitial : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceInterstitialDelegate> delegate;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;


/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceInterstitialDelegate>)delegate;

/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showAdFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
