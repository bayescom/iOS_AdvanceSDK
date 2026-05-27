//
//  AdvFunlinkSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkSplashAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvFunlinkSplashAdapter () <FLinkSplashDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property (nonatomic, strong) FLinkSplashManager *flink_ad;

@end

@implementation AdvFunlinkSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkSplashManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.bottomView = config[kAdvanceSplashBottomViewKey];
    [_flink_ad loadAdData];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    [_flink_ad showSplashAdWithWindow:window];
}

- (BOOL)adapter_isAdValid {
    return _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_flink_ad sendWinNotificationWithPrice:result.secondPrice];
    } else {
        [_flink_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - FLinkSplashDelegate
- (void)splashAdDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge splash_didLoadAdWithAdapter:self price:ecpm];
}

- (void)splashAdDidFailed:(NSError *)error {
    [self.bridge splash_failedToLoadAdWithAdapter:self error:error];
}

- (void)splashAdDidVisible {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

- (void)splashAdFailToVisible:(NSError *)error {
    [self.bridge splash_failedToShowAdWithAdapter:self error:error];
}

- (void)splashAdDidClickedWithUrlStr:(NSString *_Nullable)urlStr {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)splashAdDidShowFinish {
    [self.bridge splash_didAdClosedWithAdapter:self];
}


- (void)dealloc {
    
}

@end
