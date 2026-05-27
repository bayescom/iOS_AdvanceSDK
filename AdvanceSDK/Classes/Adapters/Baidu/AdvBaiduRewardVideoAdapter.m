//
//  AdvBaiduRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import "AdvBaiduRewardVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvBaiduRewardVideoAdapter ()<BaiduMobAdRewardVideoDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdRewardVideo *bd_ad;

@end

@implementation AdvBaiduRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bd_ad = [[BaiduMobAdRewardVideo alloc] init];
    _bd_ad.delegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        _bd_ad.userID = rewardVideoModel.userId;
        _bd_ad.extraInfo = rewardVideoModel.extra;
    }
    [_bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_bd_ad biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:nil];
    } else {
        [_bd_ad biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:nil];
    }
}

#pragma mark: - BaiduMobAdRewardVideoDelegate
- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video {
    [self.bridge rewardVideo_didLoadAdWithAdapter:self price:[[video getECPMLevel] integerValue]];
}

- (void)rewardedAdLoadFailCode:(NSString *)errCode
                       message:(NSString *)message
                    rewardedAd:(BaiduMobAdRewardVideo *)video {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge rewardVideo_failedToLoadAdWithAdapter:self error:error];
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.bridge rewardVideo_failedToShowAdWithAdapter:self error:error];
}

- (void)rewardedVideoAdDidExposured:(BaiduMobAdRewardVideo *)video {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)rewardedVideoAdRewardDidSuccess:(BaiduMobAdRewardVideo *)video verify:(BOOL)verify {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
