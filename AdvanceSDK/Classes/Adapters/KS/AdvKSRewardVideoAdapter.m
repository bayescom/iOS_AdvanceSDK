//
//  AdvKSRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSRewardVideoAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvKSRewardVideoAdapter ()<KSRewardedVideoAdDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) KSRewardedVideoAd *ks_ad;

@end

@implementation AdvKSRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    NSString *serverRewardName = config[kAdvanceServerRewardNameKey];
    NSInteger serverRewardCount = [config[kAdvanceServerRewardCountKey] integerValue];
    KSRewardedVideoModel *model = [[KSRewardedVideoModel alloc] init];
    if (rewardVideoModel || (serverRewardName && serverRewardCount)) {
        model.userId = rewardVideoModel.userId;
        model.extra = rewardVideoModel.extra;
        model.amount = rewardVideoModel.rewardAmount ?: serverRewardCount;
        model.name = rewardVideoModel.rewardName ?: serverRewardName;
    }
    _ks_ad = [[KSRewardedVideoAd alloc] initWithPosId:placementId rewardedVideoModel:model];
    _ks_ad.shouldMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _ks_ad.delegate = self;
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _ks_ad.isValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_ks_ad setBidEcpm:result.winPrice highestLossEcpm:result.secondPrice];
    } else {
        KSAdExposureReportParam *param = [[KSAdExposureReportParam alloc] init];
        param.winEcpm = result.winPrice;
        [_ks_ad reportAdExposureFailed:KSAdExposureFailureBidFailed reportParam:param];
    }
}


#pragma mark: - KSRewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:rewardedVideoAd.ecpm];
}

- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)rewardedVideoAdDidVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)rewardedVideoAdDidClick:(KSRewardedVideoAd *)rewardedVideoAd  {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)rewardedVideoAdDidClose:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd hasReward:(BOOL)hasReward {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
