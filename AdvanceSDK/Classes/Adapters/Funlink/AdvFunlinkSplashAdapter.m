//
//  AdvFunlinkSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkSplashAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvFunlinkSplashAdapter () <FLinkSplashDelegate, AdvanceSplashCommonAdapter>

@property (nonatomic, strong) FLinkSplashManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvFunlinkSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _flink_ad = [[FLinkSplashManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.bottomView = config[kAdvanceSplashBottomViewKey];
}

- (void)adapter_loadAd {
    [self.flink_ad loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [self.flink_ad showSplashAdWithWindow:window];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
    if (!valid) {
        [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

#pragma mark: - FLinkSplashDelegate
- (void)splashAdDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate splashAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)splashAdDidFailed:(NSError *)error {
    [self.delegate splashAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)splashAdDidVisible {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)splashAdFailToVisible:(NSError *)error {
    [self.delegate splashAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)splashAdDidClickedWithUrlStr:(NSString *_Nullable)urlStr {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)splashAdDidShowFinish {
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}


- (void)dealloc {
    
}

@end
