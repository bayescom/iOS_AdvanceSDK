//
//  AdvBaiduInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/6/21.
//

#import "AdvBaiduInterstitialAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvBaiduInterstitialAdapter ()<BaiduMobAdExpressIntDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdExpressInterstitial *bd_ad;

@end

@implementation AdvBaiduInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bd_ad = [[BaiduMobAdExpressInterstitial alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.delegate = self;
    [_bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_bd_ad biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    } else {
        [_bd_ad biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    }
}

#pragma mark: - BaiduMobAdExpressIntDelegate
- (void)interstitialAdLoaded:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.bridge interstitial_didLoadAdWithAdapter:self price:[[interstitial getECPMLevel] integerValue]];
}

- (void)interstitialAdLoadFailCode:(NSString *)errCode
                           message:(NSString *)message
                    interstitialAd:(BaiduMobAdExpressInterstitial *)interstitial {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge interstitial_failedToLoadAdWithAdapter:self error:error];
}

- (void)interstitialAdExposure:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)interstitialAdExposureFail:(BaiduMobAdExpressInterstitial *)interstitial withError:(int)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)interstitialAdDidClick:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)interstitialAdDidClose:(BaiduMobAdExpressInterstitial *)interstitial {
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
