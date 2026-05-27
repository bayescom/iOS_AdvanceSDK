//
//  SigmobRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/17.
//

#import "AdvSigmobRewardVideoAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"
#import "NSString+Adv.h"

@interface AdvSigmobRewardVideoAdapter () <WindRewardVideoAdDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) WindRewardVideoAd *sigmob_ad;

@end

@implementation AdvSigmobRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        request.userId = rewardVideoModel.userId;
        request.options = [NSString adv_dictionaryWithJsonString:rewardVideoModel.extra];
    }
    _sigmob_ad = [[WindRewardVideoAd alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
    [_sigmob_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_sigmob_ad showAdFromRootViewController:rootViewController options:nil];
}

- (BOOL)adapter_isAdValid {
    return _sigmob_ad.ready;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    //[_sigmob_ad sendWinNotificationWithInfo:@{AUCTION_PRICE: @(secondPrice)}];
}


#pragma mark: - WindRewardVideoAdDelegate
- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:rewardVideoAd.getEcpm.integerValue];
}

- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError *)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)rewardVideoAdDidVisible:(WindRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)rewardVideoAdDidShowFailed:(WindRewardVideoAd *)rewardVideoAd error:(NSError *)error {
    [self.bridge rewardVideo_failedToShowAdWithAdapter:self error:error];
}

- (void)rewardVideoAdDidClick:(WindRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)rewardVideoAdDidClose:(WindRewardVideoAd *)rewardVideoAd {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)rewardVideoAd:(WindRewardVideoAd *)rewardVideoAd reward:(WindRewardInfo *)reward {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)rewardVideoAdDidPlayFinish:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError * _Nullable)error {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

@end
