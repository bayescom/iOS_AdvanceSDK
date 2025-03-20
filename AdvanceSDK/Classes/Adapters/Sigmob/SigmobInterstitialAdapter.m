//
//  SigmobInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/18.
//

#import "SigmobInterstitialAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceInterstitial.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface SigmobInterstitialAdapter () <WindNewIntersititialAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) WindNewIntersititialAd *sigmob_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation SigmobInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        WindAdRequest *request = [WindAdRequest request];
        request.placementId = supplier.adspotid;
        _sigmob_ad = [[WindNewIntersititialAd alloc] initWithRequest:request];
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
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= WindNewIntersititialAdDelegate =======================
/// 广告加载成功回调
- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd {
    [self.adspot.manager setECPMIfNeeded:intersititialAd.getEcpm.integerValue supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/// 广告加载错误回调
- (void)intersititialAdDidLoad:(WindNewIntersititialAd *)intersititialAd didFailWithError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/// 广告曝光回调
- (void)intersititialAdDidVisible:(WindNewIntersititialAd *)intersititialAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)intersititialAdDidClick:(WindNewIntersititialAd *)intersititialAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告闭关回调
- (void)intersititialAdDidClose:(WindNewIntersititialAd *)intersititialAd {
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
