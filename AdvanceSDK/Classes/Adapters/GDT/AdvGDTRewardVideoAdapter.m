//
//  AdvGDTRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTRewardVideoAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvGDTRewardVideoAdapter () <GDTRewardedVideoAdDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) GDTRewardVideoAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvGDTRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
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
}

- (void)adapter_loadAd {
    [_gdt_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_gdt_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _gdt_ad.isAdValid;
    if (!valid) {
        [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - GDTRewardedVideoAdDelegate
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:rewardedVideoAd.eCPM];
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd info:(NSDictionary *)info {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
