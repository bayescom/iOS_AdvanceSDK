//
//  AdvFunlinkInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkInterstitialAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvFunlinkInterstitialAdapter () <FLinkInterstitialDelegate, AdvanceInterstitialCommonAdapter>
@property (nonatomic, strong) FLinkInterstitialManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvFunlinkInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _flink_ad = [[FLinkInterstitialManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
}

- (void)adapter_loadAd {
    [_flink_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    _flink_ad.showAdController = rootViewController;
    [_flink_ad showInterstitialAd];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
    if (!valid) {
        [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (void)adapter_sendWinNotificationWithSecondPrice:(NSInteger)secondPrice winPrice:(NSInteger)winPrice {
    [_flink_ad sendWinNotificationWithPrice:secondPrice];
}

- (void)adapter_sendLossNotificationWithFirstPrice:(NSInteger)firstPrice {
    [_flink_ad sendLossNotificationWithPrice:firstPrice];
}

#pragma mark: - FLinkInterstitialDelegate
- (void)interstitialAdDidLoad  {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate interstitialAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)interstitialAdDidFailed:(NSError *)error {
    [self.delegate interstitialAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)interstitialAdDidVisible {
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)interstitialAdDidClick {
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)interstitialAdDidAutoClose:(BOOL)autoClose {
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
