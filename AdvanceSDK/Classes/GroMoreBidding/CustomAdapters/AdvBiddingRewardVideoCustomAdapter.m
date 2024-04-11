//
//  AdvBiddingRewardVideoCustomAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import "AdvBiddingRewardVideoCustomAdapter.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import <AdvanceSDK/AdvanceRewardVideo.h>
#import "GroMoreBiddingManager.h"

@interface AdvBiddingRewardVideoCustomAdapter () <ABUCustomRewardedVideoAdapter, AdvanceRewardedVideoDelegate>

@property (nonatomic, strong) AdvanceRewardVideo *advanceRewardVideo;
@property (nonatomic, assign) NSInteger biddingType;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingRewardVideoCustomAdapter

- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

// Client Bidding的结果回调
- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    
}

- (void)loadRewardedVideoAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
    
    _biddingType = [[parameter objectForKey:ABUAdLoadingParamBiddingType] integerValue];
    _advanceRewardVideo = [[AdvanceRewardVideo alloc] initWithAdspotId:slotID
                                                                 customExt:nil
                                                            viewController:nil];

    _advanceRewardVideo.delegate = self;
    _advanceRewardVideo.muted = [parameter[ABUAdLoadingParamRVIsMute] boolValue];
    /// 并发加载各个渠道SDK
    [_advanceRewardVideo catchBidTargetWhenGroMoreBiddingWithPolicyModel:GroMoreBiddingManager.policyModel];

}

- (BOOL)showAdFromRootViewController:(UIViewController * _Nonnull)viewController parameter:(nonnull NSDictionary *)parameter {
    if (self.advanceRewardVideo.isAdValid) {
        [self.advanceRewardVideo showAdFromViewController:viewController];
        return YES;
    }
    return NO;
}

#pragma mark: - AdvanceRewardedVideoDelegate

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {

    [self.bridge rewardedVideoAd:self didLoadFailWithError:error ext:description];
}

- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
}

/// 广告数据拉取成功
- (void)didFinishLoadingRewardedVideoADWithSpotId:(NSString *)spotId {
    NSMutableDictionary *extra = [@{} mutableCopy];
    if (self.biddingType == 1) { // client
        NSString *cpm = [NSString stringWithFormat:@"%ld", (long)self.price];
        [extra setObject:cpm forKey:ABUMediaAdLoadingExtECPM];
    }
    [self.bridge rewardedVideoAd:self didLoadWithExt:extra];
}

/// 视频缓存成功
- (void)rewardedVideoDidDownLoadForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge rewardedVideoAdVideoDidLoad:self];
}

/// 激励视频开始播放
- (void)rewardedVideoDidStartPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge rewardedVideoAdDidVisible:self];
}

/// 激励视频播放完成
- (void)rewardedVideoDidEndPlayingForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge rewardedVideoAd:self didPlayFinishWithError:nil];
}

/// 广告点击
- (void)rewardedVideoDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge rewardedVideoAdDidClick:self];
    [self.bridge rewardedVideoAdWillPresentFullScreenModel:self];
}

/// 广告关闭
- (void)rewardedVideoDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceRewardVideo = nil;
    [self.bridge rewardedVideoAdDidClose:self];
}

/// 到达激励时间
- (void)rewardedVideoDidRewardSuccessForSpotId:(NSString *)spotId extra:(NSDictionary *)extra rewarded:(BOOL)rewarded {
    [self.bridge rewardedVideoAd:self didServerRewardSuccessWithInfo:^(ABUAdapterRewardAdInfo * _Nonnull info) {
        info.verify = rewarded;
    }];
}

@end
