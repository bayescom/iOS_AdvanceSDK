//
//  CsjInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjInterstitialAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface CsjInterstitialAdapter () <BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCanch;

@end

@implementation CsjInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = (AdvanceInterstitial *)adspot;
        _supplier = supplier;
        _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:_supplier.adspotid];
        _csj_ad.delegate = self;
    }
    return self;
}


- (void)loadAd {
    [super loadAd];
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
    [self unifiedDelegate];

}

- (void)supplierStateFailed {
//    NSLog(@"失败 失败失败失败失败失败失败失败  %ld", _supplier.priority);
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
}



- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (_csj_ad) {
        _csj_ad.delegate = nil;
        _csj_ad = nil;
    }
}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}



- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}



// MARK: ======================= BUNativeExpressFullscreenVideoAdDelegate =======================
/// 广告预加载成功回调
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    
}

/// 广告预加载失败回调
- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }
    [self deallocAdapter];
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    _supplier.supplierPrice = [ext[@"price"] integerValue];
//回调后再去展示广告，可保证播放和展示效果
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
}

/// 渲染失败
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self deallocAdapter];
//    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 广告曝光回调
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告关闭回调
- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告播放结束
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {

}

- (void)unifiedDelegate {
    if (_isCanch) {
        return;
    }
    _isCanch = YES;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

@end
