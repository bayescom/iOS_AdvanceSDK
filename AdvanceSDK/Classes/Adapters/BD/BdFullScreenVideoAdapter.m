//
//  BdFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//

#import "BdFullScreenVideoAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdExpressFullScreenVideo.h>
#import "AdvanceFullScreenVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface BdFullScreenVideoAdapter ()<BaiduMobAdExpressFullScreenVideoDelegate, AdvanceAdapter>
@property (nonatomic, strong) BaiduMobAdExpressFullScreenVideo *bd_ad;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation BdFullScreenVideoAdapter

@synthesize isWinnerAdapter = _isWinnerAdapter;
@synthesize isVideoCached = _isVideoCached;


- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdExpressFullScreenVideo alloc] init];
        _bd_ad.delegate = self;
        _bd_ad.AdUnitTag = _supplier.adspotid;
        _bd_ad.publisherId = _supplier.mediaid;
        _bd_ad.adType = BaiduMobAdTypeFullScreenVideo;
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
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }
    if (_isVideoCached && [self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (BOOL)isAdValid {
    return _bd_ad.isReady;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - expressFullVideoDelegate

- (void)fullScreenVideoAdLoadSuccess:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.adspot.manager setECPMIfNeeded:[[video getECPMLevel] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)fullScreenVideoAdLoadFailCode:(NSString *)errCode message:(NSString *)message fullScreenAd:(BaiduMobAdExpressFullScreenVideo *)video {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:errCode.intValue userInfo:@{@"msg": (message ?: @"")}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)fullScreenVideoAdLoaded:(BaiduMobAdExpressFullScreenVideo *)video {
    _isVideoCached = YES;
    /// 竞胜方才进行缓存成功回调
    if (_isWinnerAdapter && [self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)fullScreenVideoAdLoadFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:reason userInfo:@{@"desc":@"百度全屏视频广告缓存错误"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)fullScreenVideoAdShowFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)fullScreenVideoAdDidStarted:(BaiduMobAdExpressFullScreenVideo *)video {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)fullScreenVideoAdDidPlayFinish:(BaiduMobAdExpressFullScreenVideo *)video {
    
//    NSLog(@"全屏视频完成播放");
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)fullScreenVideoAdDidClick:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"全屏视频被点击，progress:%f", progress);
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}


- (void)fullScreenVideoAdDidClose:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"全屏视频点击关闭，progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidCloseForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)fullScreenVideoAdDidSkip:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress{
//    NSLog(@"全屏视频点击跳过，progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidClickSkipForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidClickSkipForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }

}


@end
