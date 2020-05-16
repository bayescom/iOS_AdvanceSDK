//
//  GdtRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtRewardVideoAdapter.h"
#if __has_include(<GDTRewardVideoAd.h>)
#import <GDTRewardVideoAd.h>
#else
#import "GDTRewardVideoAd.h"
#endif
#import "AdvanceRewardVideo.h"

@interface GdtRewardVideoAdapter () <GDTRewardedVideoAdDelegate>
@property (nonatomic, strong) GDTRewardVideoAd *gdt_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;

@end

@implementation GdtRewardVideoAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceRewardVideo *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _gdt_ad = [[GDTRewardVideoAd alloc] initWithPlacementId:_adspot.currentSdkSupplier.adspotid];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd];
}

- (void)showAd {
    [_gdt_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= GdtRewardVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdReady)]) {
        [self.delegate advanceRewardVideoOnAdReady];
    }
}

/// 广告加载失败回调
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _gdt_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

//视频缓存成功回调
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
    /// 视频广告视频可以调用Show方法
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoIsReadyToShow)]) {
        [self.delegate advanceRewardVideoIsReadyToShow];
    }
}

/// 视频广告曝光回调
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdShow)]) {
        [self.delegate advanceRewardVideoOnAdShow];
    }
}

/// 视频播放页关闭回调
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdClosed)]) {
        [self.delegate advanceRewardVideoOnAdClosed];
    }
}

/// 视频广告信息点击回调
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdClicked)]) {
        [self.delegate advanceRewardVideoOnAdClicked];
    }
}

/// 视频广告播放达到激励条件回调
- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective];
    }
}

/// 视频广告视频播放完成
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}

@end
