//
//  AdvanceFullScreenVideo.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceFullScreenVideo;
@protocol AdvanceFullScreenVideoDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onFullScreenVideoAdDidLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd;

/// 广告加载失败回调
-(void)onFullScreenVideoAdFailToLoad:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error;

/// 广告曝光回调
-(void)onFullScreenVideoAdExposured:(AdvanceFullScreenVideo *)fullscreenVideoAd;

/// 广告展示失败回调
-(void)onFullScreenVideoAdFailToPresent:(AdvanceFullScreenVideo *)fullscreenVideoAd error:(NSError *)error;

/// 广告点击回调
- (void)onFullScreenVideoAdClicked:(AdvanceFullScreenVideo *)fullscreenVideoAd;

/// 广告关闭回调
- (void)onFullScreenVideoAdClosed:(AdvanceFullScreenVideo *)fullscreenVideoAd;

/// 广告播放结束回调
- (void)onFullScreenVideoAdDidPlayFinish:(AdvanceFullScreenVideo *)fullscreenVideoAd;

@end

@interface AdvanceFullScreenVideo : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceFullScreenVideoDelegate> delegate;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;

/// 实时价格（分）
@property (nonatomic, assign) NSInteger price;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceFullScreenVideoDelegate>)delegate;

/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showAdFromViewController:(UIViewController *)viewController;

@end

NS_ASSUME_NONNULL_END
