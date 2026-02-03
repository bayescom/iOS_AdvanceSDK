//
//  SigmobRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/17.
//

#import "AdvSigmobRewardVideoAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"
#import "NSString+Adv.h"

@interface AdvSigmobRewardVideoAdapter () <WindRewardVideoAdDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) WindRewardVideoAd *sigmob_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvSigmobRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        request.userId = rewardVideoModel.userId;
        request.options = [NSString adv_dictionaryWithJsonString:rewardVideoModel.extra];
    }
    _sigmob_ad = [[WindRewardVideoAd alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_sigmob_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_sigmob_ad showAdFromRootViewController:rootViewController options:nil];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _sigmob_ad.ready;
    if (!valid) {
        [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}


#pragma mark: - WindRewardVideoAdDelegate
- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd {
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:rewardVideoAd.getEcpm.integerValue];
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:rewardVideoAd.getEcpm.integerValue];
}

- (void)rewardVideoAdDidLoad:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError *)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardVideoAdDidVisible:(WindRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)rewardVideoAdDidShowFailed:(WindRewardVideoAd *)rewardVideoAd error:(NSError *)error {
    [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardVideoAdDidClick:(WindRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)rewardVideoAdDidClose:(WindRewardVideoAd *)rewardVideoAd {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)rewardVideoAd:(WindRewardVideoAd *)rewardVideoAd reward:(WindRewardInfo *)reward {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)rewardVideoAdDidPlayFinish:(WindRewardVideoAd *)rewardVideoAd didFailWithError:(NSError * _Nullable)error {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

@end
