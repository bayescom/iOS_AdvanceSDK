//
//  CsjRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjRewardVideoAdapter.h"

#if __has_include(<BUAdSDK/BUNativeExpressRewardedVideoAd.h>)
#import <BUAdSDK/BUNativeExpressRewardedVideoAd.h>
#else
#import "BUNativeExpressRewardedVideoAd.h"
#endif
#if __has_include(<BUAdSDK/BURewardedVideoModel.h>)
#import <BUAdSDK/BURewardedVideoModel.h>
#else
#import "BURewardedVideoModel.h"
#endif

#import "AdvanceRewardVideo.h"
#import "AdvLog.h"

@interface CsjRewardVideoAdapter () <BUNativeExpressRewardedVideoAdDelegate>
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *csj_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;

@end

@implementation CsjRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
        [model setUserId:@"playable"];
        _csj_ad = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:_supplier.adspotid rewardedVideoModel:model];
        _csj_ad.delegate = self;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self.csj_ad loadAdData];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
    
    if (_isCached) {
        if ([self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
            [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
//    if (_csj_ad.isAdValid) {
        [_csj_ad showAdFromRootViewController:_adspot.viewController];
//    }
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (_csj_ad) {
        _csj_ad.delegate = nil;
        _csj_ad = nil;
    }
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

// MARK: ======================= BUNativeExpressRewardedVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {

    NSDictionary *ext = rewardedVideoAd.mediaExt;
    _supplier.supplierPrice = [ext[@"price"] integerValue];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];

//    NSLog(@"穿山甲激励视频拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    NSLog(@"--1> %@ %d", _supplier, _supplier.isParallel);
    if (_supplier.isParallel == YES) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
}

/// 广告加载失败回调
- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
//    NSLog(@"穿山甲激励视频拉取失败 %@", error);
    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

//视频缓存成功回调
- (void)nativeExpressRewardedVideoAdDidDownLoadVideo:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频广告曝光回调
- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频播放页关闭回调
- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 视频广告信息点击回调
- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    /// 视频广告视频播放完成
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    /// 视频广告播放达到激励条件回调
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForSpotId:extra:rewarded:)]) {
        [self.delegate rewardedVideoDidRewardSuccessForSpotId:self.adspot.adspotid extra:self.adspot.ext rewarded:verify];
    }
}

- (void)nativeExpressRewardedVideoAdServerRewardDidFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error
{
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }

}

// 加载错误
- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error
{
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }

    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }

}

- (void)nativeExpressRewardedVideoAdCallback:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd withType:(BUNativeExpressRewardedVideoAdType)nativeExpressVideoType {
    // 据说能解决神奇的bug
}

- (void)nativeExpressRewardedVideoAdDidClickSkip:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    // 跳过回调 穿山甲有 广点通没有
}
@end
