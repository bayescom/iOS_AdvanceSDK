//
//  BdRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import "BdRewardVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdRewardVideo.h>
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface BdRewardVideoAdapter ()<BaiduMobAdRewardVideoDelegate, AdvanceAdapter>
@property (nonatomic, strong) BaiduMobAdRewardVideo *bd_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) ServerReward *serverReward;

@end

@implementation BdRewardVideoAdapter

@synthesize isWinnerAdapter = _isWinnerAdapter;
@synthesize isVideoCached = _isVideoCached;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceRewardVideo *)adspot serverReward:(ServerReward *)serverReward {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _serverReward = serverReward;
        _bd_ad = [[BaiduMobAdRewardVideo alloc] init];
        _bd_ad.delegate = self;
        _bd_ad.adUnitTag = _supplier.adspotid;
        _bd_ad.publisherId = _supplier.mediaid;
        if (adspot.rewardedVideoModel || serverReward) {
            _bd_ad.userID = adspot.rewardedVideoModel.userId;
            _bd_ad.extraInfo = adspot.rewardedVideoModel.extra;
        }
    }
    return self;
}

- (void)loadAd {
    [_bd_ad load];
}

- (void)showAd {
    [_bd_ad showFromViewController:_adspot.viewController];
}

- (void)winnerAdapterToShowAd {
    _isWinnerAdapter = YES;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
    if (_isVideoCached && [self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (BOOL)isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video {
    [self.adspot.manager setECPMIfNeeded:[[video getECPMLevel] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)rewardedAdLoadFailCode:(NSString *)errCode
                       message:(NSString *)message
                    rewardedAd:(BaiduMobAdRewardVideo *)video {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:errCode.intValue userInfo:@{@"msg": (message ?: @"")}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
    _isVideoCached = YES;
    /// 竞胜方才进行缓存成功回调
    if (_isWinnerAdapter && [self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:reason userInfo:@{@"desc":@"百度广告缓存错误"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)rewardedVideoAdDidSkip:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
}

- (void)rewardedVideoAdRewardDidSuccess:(BaiduMobAdRewardVideo *)video verify:(BOOL)verify {
    [self.adspot.manager verifyRewardVideo:self.adspot.rewardedVideoModel supplier:self.supplier placementId:self.adspot.adspotid extra:self.adspot.ext delegate:self.delegate];
}


@end
