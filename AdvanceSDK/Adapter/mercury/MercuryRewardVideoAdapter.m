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

@interface MercuryRewardVideoAdapter () <MercuryRewardVideoAdDelegate>
@property (nonatomic, strong) MercuryRewardVideoAd *mercury_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
    }
    return self;
}

- (void)loadAd {
    _mercury_ad = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
    _mercury_ad.timeoutTime = 5;
    [_mercury_ad loadRewardVideoAd];
}

- (void)showAd {
    [_mercury_ad showAdFromVC:_adspot.viewController];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= MercuryRewardVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdReady)]) {
        [self.delegate advanceRewardVideoOnAdReady];
    }
}

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded error:error];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
    }
}

//视频缓存成功回调
- (void)mercury_rewardVideoAdVideoDidLoad {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
    /// 视频广告视频可以调用Show方法
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoIsReadyToShow)]) {
        [self.delegate advanceRewardVideoIsReadyToShow];
    }
}

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdClosed)]) {
        [self.delegate advanceRewardVideoOnAdClosed];
    }
}

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective];
    }
}

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}

@end
