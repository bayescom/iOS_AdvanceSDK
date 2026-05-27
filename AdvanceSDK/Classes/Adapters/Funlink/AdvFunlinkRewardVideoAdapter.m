//
//  AdvFunlinkRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRewardVideoAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvFunlinkRewardVideoAdapter () <FLinkRewardVideoDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) FLinkRewardVideoManager *flink_ad;

@end

@implementation AdvFunlinkRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkRewardVideoManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    [_flink_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_flink_ad showRewardVideoAdWithController:rootViewController];
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

#pragma mark: - FLinkRewardVideoDelegate
- (void)rewardedVideoDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:ecpm];
}

- (void)rewardedVideoDidFailWithError:(NSError *)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)rewardedVideoDidVisible {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)rewardedVideoDidClick {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)rewardedVideoDidClose {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)rewardedVideoDidRewardEffectiveWithExtra:(NSDictionary *)extra {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)dealloc {
    
}

@end
