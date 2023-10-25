//
//  GroMoreRewardedVideoTrigger.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import "GroMoreRewardedVideoTrigger.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import "GroMoreBiddingManager.h"

@interface GroMoreRewardedVideoTrigger () <ABURewardedVideoAdDelegate>
/// gromore 广告位对象
@property (nonatomic, strong) ABURewardedVideoAd *gmRewardedVideoAd;
/// advance 广告位对象 从最外层传递进来 负责 load and show
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) Gro_more *groMore;

@end

@implementation GroMoreRewardedVideoTrigger

- (instancetype)initWithGroMore:(Gro_more *)groMore adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _groMore = groMore;
        _gmRewardedVideoAd = [[ABURewardedVideoAd alloc] initWithAdUnitID:groMore.gromore_params.adspotid];
        _gmRewardedVideoAd.delegate = self;
        _gmRewardedVideoAd.mutedIfCan = _adspot.muted;
        _gmRewardedVideoAd.bidNotify = YES;
    }
    return self;
}

- (BOOL)isAdValid {
    return self.gmRewardedVideoAd.isReady;
}

- (void)loadAd {
    if([ABUAdSDKManager configDidLoad]) {
        [self.gmRewardedVideoAd loadAdData];
    } else {
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            [self.gmRewardedVideoAd loadAdData];
        }];
    }
}

- (void)showAd {
    if ([self isAdValid]) {
        [self.gmRewardedVideoAd showAdFromRootViewController:self.adspot.viewController];
    }
}


#pragma mark: - ABURewardedVideoAdDelegate

/// 广告加载成功回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidLoad:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoSucceed groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }

}

/// 广告加载失败回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 错误信息
- (void)rewardedVideoAd:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
    if ([self.delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [self.delegate didFailLoadingADSourceWithSpotId:self.adspot.adspotid error:error description:@{}];
    }
}

/// 广告已加载视频素材回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidDownLoadVideo:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告展示回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidVisible:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    /// 广告曝光才能获取到竞价
    ABURitInfo *info = [rewardedVideoAd getShowEcpmInfo];
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoImped groMore:_groMore error:nil];
    
    GroMoreBiddingManager.policyModel.gro_more.gromore_params.bidPrice = info.ecpm.integerValue;
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告展示失败回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 展示失败的原因
- (void)rewardedVideoAdDidShowFailed:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd error:(NSError *_Nonnull)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
}


/// 广告关闭事件回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidClose:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击详情事件回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidClick:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoClicked groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 请求的服务器验证成功包括C2C和S2S方法回调
/// @param rewardedVideoAd 广告管理对象
/// @param rewardInfo 奖励发放验证信息
/// @param verify 是否验证通过
- (void)rewardedVideoAdServerRewardDidSucceed:(ABURewardedVideoAd *)rewardedVideoAd rewardInfo:(ABUAdapterRewardAdInfo *)rewardInfo verify:(BOOL)verify {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForSpotId:extra:rewarded:)]) {
        [self.delegate rewardedVideoDidRewardSuccessForSpotId:self.adspot.adspotid extra:self.adspot.ext rewarded:verify];
    }
}

/// 广告视频播放完成或者出错回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 播放出错时的信息，播放完成时为空
- (void)rewardedVideoAd:(ABURewardedVideoAd *)rewardedVideoAd didPlayFinishWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
