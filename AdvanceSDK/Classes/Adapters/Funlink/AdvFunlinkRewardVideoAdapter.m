//
//  AdvFunlinkRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRewardVideoAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvFunlinkRewardVideoAdapter () <FLinkRewardVideoDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) FLinkRewardVideoManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvFunlinkRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _flink_ad = [[FLinkRewardVideoManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
}

- (void)adapter_loadAd {
    [_flink_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_flink_ad showRewardVideoAdWithController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
    if (!valid) {
        [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (void)adapter_sendWinNotificationWithSecondPrice:(NSInteger)secondPrice winPrice:(NSInteger)winPrice {
    [_flink_ad sendWinNotificationWithPrice:secondPrice];
}

- (void)adapter_sendLossNotificationWithFirstPrice:(NSInteger)firstPrice {
    [_flink_ad sendLossNotificationWithPrice:firstPrice];
}

#pragma mark: - FLinkRewardVideoDelegate
- (void)rewardedVideoDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)rewardedVideoDidFailWithError:(NSError *)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardedVideoDidVisible {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)rewardedVideoDidClick {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoDidClose {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoDidRewardEffectiveWithExtra:(NSDictionary *)extra {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
