//
//  AdvBaiduInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/6/21.
//

#import "AdvBaiduInterstitialAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvBaiduInterstitialAdapter ()<BaiduMobAdExpressIntDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) BaiduMobAdExpressInterstitial *bd_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvBaiduInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bd_ad = [[BaiduMobAdExpressInterstitial alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.delegate = self;
}

- (void)adapter_loadAd {
    [self.bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [self.bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

#pragma mark: - BaiduMobAdExpressIntDelegate
- (void)interstitialAdLoaded:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:[[interstitial getECPMLevel] integerValue]];
}

- (void)interstitialAdLoadFailCode:(NSString *)errCode
                           message:(NSString *)message
                    interstitialAd:(BaiduMobAdExpressInterstitial *)interstitial {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)interstitialAdExposure:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)interstitialAdExposureFail:(BaiduMobAdExpressInterstitial *)interstitial withError:(int)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)interstitialAdDidClick:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)interstitialAdDidClose:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
