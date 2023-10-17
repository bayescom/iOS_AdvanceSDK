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
#import "AdvanceAdapter.h"

@interface CsjInterstitialAdapter () <BUNativeExpressFullscreenVideoAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) BUNativeExpressFullscreenVideoAd *csj_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation CsjInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _csj_ad = [[BUNativeExpressFullscreenVideoAd alloc] initWithSlotID:_supplier.adspotid];
        _csj_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [self.csj_ad loadAdData];
}

- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

// MARK: ======================= BUNativeExpressFullscreenVideoAdDelegate =======================

- (void)nativeExpressFullscreenVideoAdDidLoad:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    NSDictionary *ext = fullscreenVideoAd.mediaExt;
    [self.adspot.manager setECPMIfNeeded:[ext[@"price"] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
    
}

- (void)nativeExpressFullscreenVideoAd:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)nativeExpressFullscreenVideoAdDidDownLoadVideo:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    
}

- (void)nativeExpressFullscreenVideoAdViewRenderSuccess:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd {
}

/// 渲染失败
- (void)nativeExpressFullscreenVideoAdViewRenderFail:(BUNativeExpressFullscreenVideoAd *)rewardedVideoAd error:(NSError *_Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

/// 广告曝光回调
- (void)nativeExpressFullscreenVideoAdDidVisible:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)nativeExpressFullscreenVideoAdDidClick:(BUNativeExpressFullscreenVideoAd *)fullscreenVideoAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
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

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


@end
