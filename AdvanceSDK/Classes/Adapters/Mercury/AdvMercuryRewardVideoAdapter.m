//
//  AdvMercuryRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryRewardVideoAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvMercuryRewardVideoAdapter () <MercuryRewardVideoAdDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) MercuryRewardVideoAd *mercury_ad;

@end

@implementation AdvMercuryRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _mercury_ad = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:placementId delegate:self];
    
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    NSString *serverRewardName = config[kAdvanceServerRewardNameKey];
    NSInteger serverRewardCount = [config[kAdvanceServerRewardCountKey] integerValue];
    if (rewardVideoModel || (serverRewardName && serverRewardCount)) {
        MercuryRewardedVideoModel *model = [[MercuryRewardedVideoModel alloc] init];
        model.userId = rewardVideoModel.userId;
        model.extra = rewardVideoModel.extra;
        model.rewardAmount = rewardVideoModel.rewardAmount ?: serverRewardCount;
        model.rewardName = rewardVideoModel.rewardName ?: serverRewardName;
        _mercury_ad.rewardedVideoModel = model;
    }
    [_mercury_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_mercury_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _mercury_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [_mercury_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - MercuryRewardVideoAdDelegate
- (void)mercury_rewardVideoAdDidLoad:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:rewardVideoAd.price];
}

- (void)mercury_rewardVideoAd:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)mercury_rewardVideoAdDidExposed:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)mercury_rewardVideoAdDidClicked:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)mercury_rewardVideoAdDidClose:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)mercury_rewardVideoAdDidRewardEffective:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)mercury_rewardVideoAdDidPlayFinish:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
