//
//  CsjFullScreenVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjFullScreenVideoAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceFullScreenVideo.h"
#import "AdvLog.h"

@interface CsjFullScreenVideoAdapter () <BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;

@end

@implementation CsjFullScreenVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        
        _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:_supplier.adspotid];
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
    _csj_ad.delegate = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self.csj_ad loadAdData];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }
    
    if (_isCached) {
        if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
            [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
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
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}


// MARK: ======================= BUNativeExpressFullscreenVideoAdDelegate =======================
/// 广告预加载成功回调
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    _supplier.supplierPrice = [ext[@"price"] integerValue];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed  supplier:_supplier error:nil];
//    NSLog(@"穿山甲全屏视频拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }
}

/// 广告视频缓存成功
- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告预加载失败回调
- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }
    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 渲染失败
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 广告曝光回调
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告关闭回调
- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidCloseForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告播放结束
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidEndPlayingForSpotId:extra:)]) {
            [self.delegate fullscreenVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

// 点击了跳过
- (void)nativeExpressFullscreenVideoAdDidClickSkip:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickSkipForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickSkipForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}



- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
    
}


@end
