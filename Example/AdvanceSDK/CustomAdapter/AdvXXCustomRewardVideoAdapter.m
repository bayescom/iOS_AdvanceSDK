//
//  AdvXXCustomRewardVideoAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/8.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomRewardVideoAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvanceCommonAdapter.h>
#import <AdvanceSDK/AdvAdConfigHeader.h>
#import <AdvanceSDK/AdvRewardVideoModel.h>

@interface AdvXXCustomRewardVideoAdapter () <BUNativeExpressRewardedVideoAdDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *rewardVideoAd;

@end

@implementation AdvXXCustomRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    NSString *serverRewardName = config[kAdvanceServerRewardNameKey];
    NSInteger serverRewardCount = [config[kAdvanceServerRewardCountKey] integerValue];
    BURewardedVideoModel *model = [[BURewardedVideoModel alloc] init];
    if (rewardVideoModel || (serverRewardName && serverRewardCount)) {
        model.userId = rewardVideoModel.userId;
        model.extra = rewardVideoModel.extra;
        model.rewardAmount = rewardVideoModel.rewardAmount ?: serverRewardCount;
        model.rewardName = rewardVideoModel.rewardName ?: serverRewardName;
    }
    _rewardVideoAd = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:placementId rewardedVideoModel:model];
    _rewardVideoAd.delegate = self;
    [_rewardVideoAd loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_rewardVideoAd showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_rewardVideoAd win:@(result.secondPrice)];
    } else {
        [_rewardVideoAd loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark: - BUNativeExpressRewardedVideoAdDelegate
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    NSDictionary *ext = rewardedVideoAd.mediaExt;
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    [self.bridge rewardVideo_failedToShowAdWithAdapter:self error:error];
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
