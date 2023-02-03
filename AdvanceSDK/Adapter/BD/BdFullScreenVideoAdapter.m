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
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    
    if (_isCached) {
        if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdVideoCached)]) {
            [self.delegate advanceFullScreenVideoOnAdVideoCached];
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

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - expressFullVideoDelegate

- (void)fullScreenVideoAdLoadSuccess:(BaiduMobAdExpressFullScreenVideo *)video {
    //    ADVLog(@"百度全屏视频拉取成功");
    _supplier.supplierPrice = [[video getECPMLevel] integerValue];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        ADVLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }


}

- (void)fullScreenVideoAdLoaded:(BaiduMobAdExpressFullScreenVideo *)video {
//    ADVLog(@"百度全屏视频缓存成功");
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdVideoCached)]) {
        [self.delegate advanceFullScreenVideoOnAdVideoCached];
    }
}

- (void)fullScreenVideoAdLoadFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
//    ADVLog(@"全屏视频缓存失败，failReason：%d", reason);
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }
    _bd_ad = nil;

}

- (void)fullScreenVideoAdShowFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
//    NSLog(@"全屏视频展现失败，failReason：%d", reason);
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000040 + reason userInfo:@{@"desc":@"百度广告渲染失败"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
}

- (void)fullScreenVideoAdDidStarted:(BaiduMobAdExpressFullScreenVideo *)video {
//    NSLog(@"全屏视频开始播放");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

- (void)fullScreenVideoAdDidPlayFinish:(BaiduMobAdExpressFullScreenVideo *)video {
    
//    NSLog(@"全屏视频完成播放");
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdPlayFinish)]) {
        [self.delegate advanceFullScreenVideoOnAdPlayFinish];
    }
}

- (void)fullScreenVideoAdDidClick:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"全屏视频被点击，progress:%f", progress);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}


- (void)fullScreenVideoAdDidClose:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"全屏视频点击关闭，progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)fullScreenVideoAdDidSkip:(BaiduMobAdExpressFullScreenVideo *)video withPlayingProgress:(CGFloat)progress{
//    NSLog(@"全屏视频点击跳过，progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideodDidClickSkip)]) {
        [self.delegate advanceFullScreenVideodDidClickSkip];
    }

}


@end
