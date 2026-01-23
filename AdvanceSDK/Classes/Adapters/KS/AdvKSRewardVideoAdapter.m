//
//  AdvKSRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSRewardVideoAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvKSRewardVideoAdapter ()<KSRewardedVideoAdDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) KSRewardedVideoAd *ks_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvKSRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
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
}

- (void)adapter_loadAd {
    [_ks_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_ks_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _ks_ad.isValid;
    if (!valid) {
        [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - KSRewardedVideoAdDelegate
- (void)rewardedVideoAdDidLoad:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:rewardedVideoAd.ecpm];
}

- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardedVideoAdDidVisible:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidClick:(KSRewardedVideoAd *)rewardedVideoAd  {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidClose:(KSRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAd:(KSRewardedVideoAd *)rewardedVideoAd hasReward:(BOOL)hasReward {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidPlayFinish:(KSRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
