//
//  AdvanceRewardVideo.h
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvRewardVideoModel.h"
#import "AdvRewardCallbackInfo.h"

NS_ASSUME_NONNULL_BEGIN

@class AdvanceRewardVideo;
@protocol AdvanceRewardVideoDelegate <NSObject>

@optional

/// 广告加载成功回调
- (void)onRewardVideoAdDidLoad:(AdvanceRewardVideo *)rewardVideoAd;

/// 广告加载失败回调
-(void)onRewardVideoAdFailToLoad:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error;

/// 广告曝光回调
-(void)onRewardVideoAdExposured:(AdvanceRewardVideo *)rewardVideoAd;

/// 广告展示失败回调
-(void)onRewardVideoAdFailToPresent:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error;

/// 广告点击回调
- (void)onRewardVideoAdClicked:(AdvanceRewardVideo *)rewardVideoAd;

/// 广告关闭回调
- (void)onRewardVideoAdClosed:(AdvanceRewardVideo *)rewardVideoAd;

/// 广告奖励发放成功回调
- (void)onRewardVideoAdDidRewardSuccess:(AdvanceRewardVideo *)rewardVideoAd rewardInfo:(AdvRewardCallbackInfo *)rewardInfo;

/// 服务端验证奖励失败回调
- (void)onRewardVideoAdDidServerRewardFail:(AdvanceRewardVideo *)rewardVideoAd error:(NSError *)error;

/// 广告播放结束回调
- (void)onRewardVideoAdDidPlayFinish:(AdvanceRewardVideo *)rewardVideoAd;

@end

@interface AdvanceRewardVideo : AdvanceBaseAdSpot

/// 广告代理
@property (nonatomic, weak) id<AdvanceRewardVideoDelegate> delegate;

/// 奖励信息
@property (nonatomic, strong) AdvRewardVideoModel *rewardVideoModel;

/// 设定是否静音播放视频，默认为YES
@property (nonatomic, assign) BOOL muted;

/// 广告是否有效，建议在展示广告之前判断，否则会影响计费或展示失败
@property (nonatomic, readonly) BOOL isAdValid;


/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
/// @param delegate 代理
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra
                        delegate:(nullable id<AdvanceRewardVideoDelegate>)delegate;

/// 加载广告
- (void)loadAd;

/// 展示广告
- (void)showAdFromViewController:(UIViewController *)viewController;


@end

NS_ASSUME_NONNULL_END
