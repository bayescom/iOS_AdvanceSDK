//
//  AdvMercuryRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryRewardVideoAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvMercuryRewardVideoAdapter () <MercuryRewardVideoAdDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) MercuryRewardVideoAd *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvMercuryRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
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
}

- (void)adapter_loadAd {
    [_mercury_ad loadAd];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_mercury_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _mercury_ad.isAdValid;
    if (!valid) {
        [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - MercuryRewardVideoAdDelegate
- (void)mercury_rewardVideoAdDidLoad:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:rewardVideoAd.price];
}

- (void)mercury_rewardVideoAd:(MercuryRewardVideoAd *_Nonnull)rewardVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)mercury_rewardVideoAdDidExposed:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)mercury_rewardVideoAdDidClicked:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)mercury_rewardVideoAdDidClose:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)mercury_rewardVideoAdDidRewardEffective:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)mercury_rewardVideoAdDidPlayFinish:(MercuryRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
