//
//  BdFullScreenVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/6/1.
//

#import "BdFullScreenVideoAdapter.h"

#if __has_include(<BaiduMobAdSDK/BaiduMobAdExpressFullScreenVideo.h>)
#import <BaiduMobAdSDK/BaiduMobAdExpressFullScreenVideo.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdExpressFullScreenVideo.h"
#endif

#import "AdvanceFullScreenVideo.h"
#import "AdvLog.h"
@interface BdFullScreenVideoAdapter ()<BaiduMobAdExpressFullScreenVideoDelegate>
@property (nonatomic, strong) BaiduMobAdExpressFullScreenVideo *bd_ad;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;
@end

@implementation BdFullScreenVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
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

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_bd_ad load];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }
    
    if (_isCached) {
        if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
            [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }

}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)deallocAdapter {
    
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    [_bd_ad showFromViewController:_adspot.viewController];
    
}

- (BOOL)isAdValid {
    return _bd_ad.isReady;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - expressFullVideoDelegate

- (void)fullScreenVideoAdLoadSuccess:(BaiduMobAdExpressFullScreenVideo *)video {
    //    ADVLog(@"百度全屏视频拉取成功");
    _supplier.supplierPrice = [[video getECPMLevel] integerValue];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        ADVLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingFullscreenVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingFullscreenVideoADWithSpotId:self.adspot.adspotid];
    }


}

- (void)fullScreenVideoAdLoadFailCode:(NSString *)errCode message:(NSString *)message fullScreenAd:(BaiduMobAdExpressFullScreenVideo *)video {
    ADVLog(@"全屏视频加载失败，errCode:%@, message:%@", errCode, message);
}

- (void)fullScreenVideoAdLoaded:(BaiduMobAdExpressFullScreenVideo *)video {
//    ADVLog(@"百度全屏视频缓存成功");
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(fullscreenVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate fullscreenVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)fullScreenVideoAdLoadFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
//    ADVLog(@"全屏视频缓存失败，failReason：%d", reason);
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed  supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }
    _bd_ad = nil;

}

- (void)fullScreenVideoAdShowFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
//    NSLog(@"全屏视频展现失败，failReason：%d", reason);
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000040 + reason userInfo:@{@"desc":@"百度广告渲染失败"}];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed  supplier:_supplier error:error];
}

- (void)fullScreenVideoAdDidStarted:(BaiduMobAdExpressFullScreenVideo *)video {
//    NSLog(@"全屏视频开始播放");
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
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
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
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
