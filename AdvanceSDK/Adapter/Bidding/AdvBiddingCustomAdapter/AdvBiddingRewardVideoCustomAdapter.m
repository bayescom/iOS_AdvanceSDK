//
//  AdvBiddingRewardVideoCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/10.
//

#import "AdvBiddingRewardVideoCustomAdapter.h"
#import <AdvanceSDK/AdvanceRewardVideo.h>
#import "AdvBiddingCongfig.h"
#import "AdvSupplierModel.h"
#import "UIApplication+Adv.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

@interface AdvBiddingRewardVideoCustomAdapter ()<AdvanceRewardVideoDelegate, ABUCustomRewardedVideoAdapter>
@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingRewardVideoCustomAdapter
- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (void)loadRewardedVideoAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
    NSLog(@"----------->自定义激励视频adapter开始加载啦啦<------------");
    AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];

    NSLog(@"--> %@  ", [UIApplication sharedApplication].adv_getCurrentWindow.rootViewController);
    self.advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:slotID
                                                            viewController:[UIApplication sharedApplication].adv_getCurrentWindow.rootViewController];

    self.advanceRewardVideo.delegate = self;

    [self.advanceRewardVideo loadAdWithSupplierModel:model];



}

- (BOOL)showAdFromRootViewController:(UIViewController * _Nonnull)viewController parameter:(nonnull NSDictionary *)parameter {
    NSLog(@"----------->自定义激励视频adapter展示啦加载啦啦<------------");
    self.viewController = viewController;
    
    [self.advanceRewardVideo showAd];

    return YES;
}

- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
}

- (void)advanceBiddingEndWithPrice:(NSInteger)price {
    self.price = price;
    NSLog(@"bidding结束 %s %ld", __func__, self.price);
}

- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功, 正在缓存... %s %ld", __func__, self.price);
    [self.bridge rewardedVideoAd:self didLoadWithExt:@{ABUMediaAdLoadingExtECPM:[NSString stringWithFormat:@"%ld", self.price]}];
}

/// 视频缓存成功
- (void)advanceRewardVideoOnAdVideoCached {
    NSLog(@"视频缓存成功 %s", __func__);
    [self.bridge rewardedVideoAdVideoDidLoad:self];
}

/// 到达激励时间
- (void)advanceRewardVideoAdDidRewardEffective:(BOOL)isReward {
    NSLog(@"到达激励时间 %s %d", __func__, isReward);
    [self.bridge rewardedVideoAd:self didServerRewardSuccessWithInfo:^(ABUAdapterRewardAdInfo * _Nonnull info) {
        info.rewardAmount = 1;
        info.verify = isReward;
    }];
}

/// 广告曝光
- (void)advanceExposured {
    NSLog(@"广告曝光回调 %s", __func__);
    [self.bridge rewardedVideoAdDidVisible:self];
}

/// 广告点击
- (void)advanceClicked {
    NSLog(@"广告点击 %s", __func__);
    [self.bridge rewardedVideoAdDidClick:self];
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error,description);

    [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:description];
}

/// 广告关闭
- (void)advanceDidClose {
    NSLog(@"广告关闭了 %s", __func__);
    [self.bridge rewardedVideoAdDidClose:self];
}

/// 播放完成
- (void)advanceRewardVideoAdDidPlayFinish {
    NSLog(@"播放完成 %s", __func__);
    [self.bridge rewardedVideoAd:self didPlayFinishWithError:nil];
}

@end
