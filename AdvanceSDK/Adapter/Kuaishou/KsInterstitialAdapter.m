//
//  KsInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import "KsInterstitialAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
#import "KSAdSDK.h"
#endif

#import "AdvanceInterstitial.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface KsInterstitialAdapter ()<KSInterstitialAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) KSInterstitialAd *ks_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@end
 
@implementation KsInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _ks_ad = [[KSInterstitialAd alloc] initWithPosId:_supplier.adspotid];
        _ks_ad.videoSoundEnabled = !_adspot.muted;
        _ks_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_ks_ad loadAdData];
}

- (void)showAd {
    [_ks_ad showFromViewController:_adspot.viewController];
}

- (void)dealloc{
    ADVLog(@"%s", __func__);
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

/**
 * interstitial ad data loaded
 */
- (void)ksad_interstitialAdDidLoad:(KSInterstitialAd *)interstitialAd {

}
/**
 * interstitial ad render success
 */
- (void)ksad_interstitialAdRenderSuccess:(KSInterstitialAd *)interstitialAd {
    [self.adspot.manager setECPMIfNeeded:interstitialAd.ecpm supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}
/**
 * interstitial ad load or render failed
 */
- (void)ksad_interstitialAdRenderFail:(KSInterstitialAd *)interstitialAd error:(NSError * _Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}
/**
 * interstitial ad will visible
 */
- (void)ksad_interstitialAdWillVisible:(KSInterstitialAd *)interstitialAd {
    
}
/**
 * interstitial ad did visible
 */
- (void)ksad_interstitialAdDidVisible:(KSInterstitialAd *)interstitialAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 * interstitial ad did skip (for video only)
 * @param playDuration played duration
 */
- (void)ksad_interstitialAd:(KSInterstitialAd *)interstitialAd didSkip:(NSTimeInterval)playDuration {
    
}
/**
 * interstitial ad did click
 */
- (void)ksad_interstitialAdDidClick:(KSInterstitialAd *)interstitialAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 * interstitial ad will close
 */
- (void)ksad_interstitialAdWillClose:(KSInterstitialAd *)interstitialAd {
    
}
/**
 * interstitial ad did close
 */
- (void)ksad_interstitialAdDidClose:(KSInterstitialAd *)interstitialAd {
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}
/**
 * interstitial ad did close other controller
 */
- (void)ksad_interstitialAdDidCloseOtherController:(KSInterstitialAd *)interstitialAd interactionType:(KSAdInteractionType)interactionType {
    
}


@end
