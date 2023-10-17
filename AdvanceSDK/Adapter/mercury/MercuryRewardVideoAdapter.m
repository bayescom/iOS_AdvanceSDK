//
//  MercuryRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryRewardVideoAdapter.h"
#if __has_include(<MercurySDK/MercuryRewardVideoAd.h>)
#import <MercurySDK/MercuryRewardVideoAd.h>
#else
#import "MercuryRewardVideoAd.h"
#endif
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface MercuryRewardVideoAdapter () <MercuryRewardVideoAdDelegate>
@property (nonatomic, strong) MercuryRewardVideoAd *mercury_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
        _mercury_ad.timeoutTime = 5;
    }
    return self;
}

- (void)loadAd {
    [_mercury_ad loadRewardVideoAd];
}

- (void)showAd {
    [_mercury_ad showAdFromVC:_adspot.viewController];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
}

- (BOOL)isAdValid {
    return YES;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= MercuryRewardVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager setECPMIfNeeded:rewardVideoAd.price supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

//视频缓存成功回调
- (void)mercury_rewardVideoAdVideoDidLoad:(MercuryRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose:(MercuryRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective:(MercuryRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForSpotId:extra:rewarded:)]) {
        [self.delegate rewardedVideoDidRewardSuccessForSpotId:self.adspot.adspotid extra:self.adspot.ext rewarded:YES];
    }
}

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish:(MercuryRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
