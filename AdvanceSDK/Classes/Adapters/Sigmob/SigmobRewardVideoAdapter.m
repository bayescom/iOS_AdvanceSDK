//
//  SigmobRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/17.
//

#import "SigmobRewardVideoAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface SigmobRewardVideoAdapter () <WindRewardVideoAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) WindRewardVideoAd *sigmob_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation SigmobRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        WindAdRequest *request = [WindAdRequest request];
        request.placementId = _supplier.adspotid;
        _sigmob_ad = [[WindRewardVideoAd alloc] initWithRequest:request];
        _sigmob_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_sigmob_ad loadAdData];
}

- (void)showAd {
    [_sigmob_ad showAdFromRootViewController:_adspot.viewController options:nil];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
}

- (BOOL)isAdValid {
    return _sigmob_ad.ready;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= WindRewardVideoAdDelegate =======================
/// 广告加载成功回调
- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager setECPMIfNeeded:rewardVideoAd.getEcpm.integerValue supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/// 广告加载错误回调
- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/// 广告曝光回调
- (void)rewardVideoAdDidVisible:(WindRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告闭关回调
- (void)rewardVideoAdDidClose:(WindRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)rewardVideoAdDidClick:(WindRewardVideoAd *)rewardVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告获得激励时回调
- (void)rewardVideoAd:(WindRewardVideoAd *)rewardVideoAd reward:(WindRewardInfo *)reward {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForSpotId:extra:rewarded:)]) {
        [self.delegate rewardedVideoDidRewardSuccessForSpotId:self.adspot.adspotid extra:self.adspot.ext rewarded:YES];
    }
}

/// 广告视频播放完成或者视频播放出错
- (void)rewardVideoAdDidPlayFinish:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError * _Nullable)error {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
