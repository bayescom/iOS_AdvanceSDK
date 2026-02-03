//
//  AdvCSJRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJRewardVideoAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvCSJRewardVideoAdapter () <BUNativeExpressRewardedVideoAdDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) BUNativeExpressRewardedVideoAd *csj_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvCSJRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
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
    _csj_ad = [[BUNativeExpressRewardedVideoAd alloc] initWithSlotID:placementId rewardedVideoModel:model];
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_csj_ad loadAdData];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_csj_ad showAdFromRootViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    return YES;
}


#pragma mark: - BUNativeExpressRewardedVideoAdDelegate
- (void)nativeExpressRewardedVideoAdDidLoad:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    NSDictionary *ext = rewardedVideoAd.mediaExt;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:[ext[@"price"] integerValue]];
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressRewardedVideoAd:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressRewardedVideoAdViewRenderFail:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd error:(NSError *)error {
    [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressRewardedVideoAdDidVisible:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeExpressRewardedVideoAdDidClick:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeExpressRewardedVideoAdDidClose:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)nativeExpressRewardedVideoAdServerRewardDidSucceed:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd verify:(BOOL)verify {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)nativeExpressRewardedVideoAdDidPlayFinish:(BUNativeExpressRewardedVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
