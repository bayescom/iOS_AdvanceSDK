//
//  CsjInterstitialProAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/20.
//

#import "CsjInterstitialProAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface CsjInterstitialProAdapter ()<BUNativeExpressFullscreenVideoAdDelegate>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCanch;

@end

@implementation CsjInterstitialProAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
//        NSLog(@"%s %@", __func__, supplier);
        _adspot = (AdvanceInterstitial *)adspot;
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
    [self unifiedDelegate];
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
}



- (void)loadAd {
//    NSLog(@"%s %@", __func__, _supplier);
    [super loadAd];
}

- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

- (void)deallocAdapter {
    if (_csj_ad) {
        _csj_ad.delegate = nil;
        _csj_ad = nil;
    }
}


// MARK: ======================= BUNativeExpressFullscreenVideoAdDelegate =======================
/// 广告预加载成功回调
- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    
}

/// 广告预加载失败回调
- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }
    [self deallocAdapter];
//    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
//回调后再去展示广告，可保证播放和展示效果
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
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
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    [self deallocAdapter];
//    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceFullScreenVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 广告曝光回调
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 广告点击回调
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 广告曝光结束回调
- (void)nativeExpressFullscreenVideoAdDidClose:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 广告播放结束
- (void)nativeExpressFullscreenVideoAdDidPlayFinish:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
//    if (!error) {
//        if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdPlayFinish)]) {
//            [self.delegate advanceFullScreenVideoOnAdPlayFinish];
//        }
//    }
}

- (void)unifiedDelegate {
    if (_isCanch) {
        return;
    }
    _isCanch = YES;
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

@end
