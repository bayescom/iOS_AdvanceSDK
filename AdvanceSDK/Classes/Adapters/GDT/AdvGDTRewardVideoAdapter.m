//
//  AdvGDTRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTRewardVideoAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvGDTRewardVideoAdapter () <GDTRewardedVideoAdDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) GDTRewardVideoAd *gdt_ad;

@end

@implementation AdvGDTRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _gdt_ad = [[GDTRewardVideoAd alloc] initWithPlacementId:placementId];
    
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        GDTServerSideVerificationOptions *model = [[GDTServerSideVerificationOptions alloc] init];
        model.userIdentifier = rewardVideoModel.userId;
        model.customRewardString = rewardVideoModel.extra;
        _gdt_ad.serverSideVerificationOptions = model;
    }
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_gdt_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return _gdt_ad.isAdValid;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_gdt_ad sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [_gdt_ad sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}


#pragma mark: - GDTRewardedVideoAdDelegate
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:rewardedVideoAd.eCPM];
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)gdt_adDidRewardEffective:(id<GDTAdProtocol>)adInstance info:(NSDictionary *)info {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
