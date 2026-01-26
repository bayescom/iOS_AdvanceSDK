//
//  AdvBaiduRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import "AdvBaiduRewardVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvBaiduRewardVideoAdapter ()<BaiduMobAdRewardVideoDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) BaiduMobAdRewardVideo *bd_ad;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvBaiduRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bd_ad = [[BaiduMobAdRewardVideo alloc] init];
    _bd_ad.delegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        _bd_ad.userID = rewardVideoModel.userId;
        _bd_ad.extraInfo = rewardVideoModel.extra;
    }
}

- (void)adapter_loadAd {
    [_bd_ad load];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [_bd_ad showFromViewController:rootViewController];
}

- (BOOL)adapter_isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}


#pragma mark: - BaiduMobAdRewardVideoDelegate
- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video {
    [self.delegate rewardAdapter_didLoadAdWithAdapterId:self.adapterId price:[[video getECPMLevel] integerValue]];
}

- (void)rewardedAdLoadFailCode:(NSString *)errCode
                       message:(NSString *)message
                    rewardedAd:(BaiduMobAdRewardVideo *)video {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate rewardAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:reason userInfo:nil];
    [self.delegate rewardAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)rewardedVideoAdDidExposured:(BaiduMobAdRewardVideo *)video {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdRewardDidSuccess:(BaiduMobAdRewardVideo *)video verify:(BOOL)verify {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
