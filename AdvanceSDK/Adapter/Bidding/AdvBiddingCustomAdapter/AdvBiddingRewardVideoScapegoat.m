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

@interface AdvBiddingRewardVideoScapegoat ()<ABUCustomSplashAdapter>
@property (nonatomic, assign) NSInteger price;
@end

@implementation AdvBiddingRewardVideoScapegoat
- (void)advanceBiddingEndWithPrice:(NSInteger)price {
    self.price = price;
//    NSLog(@"bidding结束 %s %ld", __func__, self.price);
}

- (void)advanceUnifiedViewDidLoad {
//    NSLog(@"广告数据拉取成功, 正在缓存... %s %ld", __func__, self.price);
    [self.a.bridge rewardedVideoAd:self.a didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}

/// 视频缓存成功
- (void)advanceRewardVideoOnAdVideoCached {
//    NSLog(@"视频缓存成功 %s", __func__);
    [self.a.bridge rewardedVideoAdVideoDidLoad:self.a];
}

/// 到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective:(BOOL)isReward {
//    NSLog(@"到达激励时间 %s %d", __func__, isReward);
    [self.a.bridge rewardedVideoAd:self.a didServerRewardSuccessWithInfo:^(ABUAdapterRewardAdInfo * _Nonnull info) {
        info.rewardAmount = 1;
        info.verify = isReward;
    }];
}

/// 广告曝光
- (void)advanceExposured {
//    NSLog(@"广告曝光回调 %s", __func__);
    [self.a.bridge rewardedVideoAdDidVisible:self.a];
}

/// 广告点击
- (void)advanceClicked {
//    NSLog(@"广告点击 %s", __func__);
    [self.a.bridge rewardedVideoAdDidClick:self.a];
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
//    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);

    [self.a.bridge rewardedVideoAd:self.a didLoadFailWithError:error ext:description];
}

/// 广告关闭
- (void)advanceDidClose {
//    NSLog(@"广告关闭了 %s", __func__);
    [self.a.bridge rewardedVideoAdDidClose:self.a];
}

/// 播放完成
- (void)advanceRewardVideoAdDidPlayFinish {
//    NSLog(@"播放完成 %s", __func__);
    [self.a.bridge rewardedVideoAd:self.a didPlayFinishWithError:nil];
}

@end
