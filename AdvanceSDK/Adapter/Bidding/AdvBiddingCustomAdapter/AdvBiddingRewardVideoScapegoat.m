//
//  AdvBiddingRewardVideoScapegoat.m
//  AdvanceSDK
//
//  Created by MS on 2022/10/26.
//

#import "AdvBiddingRewardVideoScapegoat.h"
#import "AdvBiddingRewardVideoCustomAdapter.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

@interface AdvBiddingRewardVideoScapegoat ()
@property (nonatomic, assign) NSInteger price;
@end

@implementation AdvBiddingRewardVideoScapegoat

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    //
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);

    [self.a.bridge rewardedVideoAd:self.a didLoadFailWithError:error ext:description];
}

- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
//    NSLog(@"bidding结束 %s %ld", __func__, self.price);
}

/// 广告数据拉取成功
- (void)didFinishLoadingRewardedVideoADWithSpotId:(NSString *)spotId {
//    NSLog(@"广告数据拉取成功, 正在缓存... %s %ld", __func__, self.price);
    [self.a.bridge rewardedVideoAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}

/// 视频缓存成功
- (void)rewardedVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"视频缓存成功 %s", __func__);
    [self.a.bridge rewardedVideoAdVideoDidLoad:self.a];
}

/// 到达激励时间
- (void)rewardedVideoDidRewardSuccessForSpotId:(NSString *)spotId extra:(NSDictionary *)extra rewarded:(BOOL)rewarded {
//    NSLog(@"到达激励时间 %s %d", __func__, isReward);
    [self.a.bridge rewardedVideoAd:self.a didServerRewardSuccessWithInfo:^(ABUAdapterRewardAdInfo * _Nonnull info) {
        info.rewardAmount = 1;
        info.verify = rewarded;
    }];
}

/// 激励视频开始播放
- (void)rewardedVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告曝光回调 %s", __func__);
    [self.a.bridge rewardedVideoAdDidVisible:self.a];
}

/// 激励视频播放完成
- (void)rewardedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"播放完成 %s", __func__);
    [self.a.bridge rewardedVideoAd:self.a didPlayFinishWithError:nil];
}

/// 广告点击
- (void)rewardedVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge rewardedVideoAdDidClick:self.a];
}

/// 广告关闭
- (void)rewardedVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
//    NSLog(@"广告关闭了 %s", __func__);
    [self.a.bridge rewardedVideoAdDidClose:self.a];
}


@end
