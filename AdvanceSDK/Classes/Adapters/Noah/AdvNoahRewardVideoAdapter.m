//
//  AdvNoahRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahRewardVideoAdapter.h"
#import <NoahSDK/NoahSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvNoahRewardVideoAdapter () <NoahSdkRewardedVideoListener, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) RewardedVideoAd *noah_ad;

@end

@implementation AdvNoahRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    RequestInfo *requestInfo = [[RequestInfo alloc] init];
    requestInfo.slotKey = placementId;
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    NSString *serverRewardName = config[kAdvanceServerRewardNameKey];
    NSInteger serverRewardCount = [config[kAdvanceServerRewardCountKey] integerValue];
    if (rewardVideoModel || (serverRewardName && serverRewardCount)) {
        requestInfo.rewardInfoCount = [NSString stringWithFormat:@"%ld", rewardVideoModel.rewardAmount ?: serverRewardCount];
        requestInfo.rewardInfoContent = rewardVideoModel.rewardName ?: serverRewardName;
        requestInfo.supportRewardCombine = YES;
    }
    [RewardedVideoAd loadAdWithReqInfo:requestInfo adDelegate:self];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_noah_ad showAdInViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _noah_ad.isValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_noah_ad sendWinNotification:result.secondPrice];
    } else {
        [_noah_ad sendLossNotification:result.winPrice reason:0];
    }
}


#pragma mark: - NoahSdkRewardedVideoListener
- (void)onReVidoAdLoaded:(RewardedVideoAd *)ad {
    self.noah_ad = ad;
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:ad.price];
}

- (void)onReVidoAdLoadFail:(RequestInfo *)reqInfo error:(AdError *)error {
    NSError *err = [NSError errorWithDomain:@"NoahAdErrorDomain" code:[error getErrorCode] userInfo:@{NSLocalizedDescriptionKey: [error getErrorMessage] ?: @""}];
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:err];
}

- (void)onReVidoAdShown:(RewardedVideoAd *)ad {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)onReVidoAdClicked:(RewardedVideoAd *)ad {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)onReVidoAdClosed:(RewardedVideoAd *)ad {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)onReVidoRewarded:(RewardedVideoAd *)ad rewardInfo:(NSDictionary *)rewardInfo {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)onReVidoEnd:(RewardedVideoAd *)ad {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
