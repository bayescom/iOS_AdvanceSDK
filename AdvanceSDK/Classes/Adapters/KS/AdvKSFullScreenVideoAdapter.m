//
//  AdvKSFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSFullScreenVideoAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceFullScreenVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvKSFullScreenVideoAdapter ()<KSFullscreenVideoAdDelegate, AdvanceFullScreenVideoCommonAdapter>
@property (nonatomic, strong) KSFullscreenVideoAd *ks_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvKSFullScreenVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _ks_ad = [[KSFullscreenVideoAd alloc] initWithPosId:placementId];
    _ks_ad.showDirection = KSAdShowDirection_Vertical;
    _ks_ad.shouldMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _ks_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _ks_ad.isValid;
    if (!valid) {
        [self.delegate fullscreenAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - KSFullscreenVideoAdDelegate
- (void)fullscreenVideoAdDidLoad:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didLoadAdWithAdapterId:self.adapterId price:fullscreenVideoAd.ecpm];
}

- (void)fullscreenVideoAd:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate fullscreenAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)fullscreenVideoAdDidVisible:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)fullscreenVideoAdDidClick:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)fullscreenVideoAdDidClose:(KSFullscreenVideoAd *)fullscreenVideoAd {
    [self.delegate fullscreenAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)fullscreenVideoAdDidPlayFinish:(KSFullscreenVideoAd *)fullscreenVideoAd didFailWithError:(NSError *_Nullable)error {
    if (!error) {
        [self.delegate fullscreenAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
    }
}

@end
