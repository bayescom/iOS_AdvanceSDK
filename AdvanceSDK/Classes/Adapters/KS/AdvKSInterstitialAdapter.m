//
//  KsInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import "AdvKSInterstitialAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvKSInterstitialAdapter ()<KSInterstitialAdDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) KSInterstitialAd *ks_ad;
@property (nonatomic, copy) NSString *adapterId;

@end
 
@implementation AdvKSInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _ks_ad = [[KSInterstitialAd alloc] initWithPosId:placementId];
    _ks_ad.videoSoundEnabled = ![config[kAdvanceAdVideoMutedKey] boolValue];
    _ks_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _ks_ad.isValid;
    if (!valid) {
        [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - KSSplashAdViewDelegate
/// 必须在此回调中处理 广告才有效
- (void)ksad_interstitialAdRenderSuccess:(KSInterstitialAd *)interstitialAd {
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:interstitialAd.ecpm];
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:interstitialAd.ecpm];
}

- (void)ksad_interstitialAdRenderFail:(KSInterstitialAd *)interstitialAd error:(NSError * _Nullable)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)ksad_interstitialAdDidVisible:(KSInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)ksad_interstitialAdDidClick:(KSInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)ksad_interstitialAdDidClose:(KSInterstitialAd *)interstitialAd {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}


@end
