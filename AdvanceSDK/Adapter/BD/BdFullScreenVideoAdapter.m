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

@end

@implementation BdFullScreenVideoAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceFullScreenVideo *)adspot {
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

- (void)deallocAdapter {
    
}


- (void)loadAd {
    ADVLog(@"加载百度 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"百度 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"百度 失败 %@", _supplier);
        _bd_ad = nil;
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"百度 正在加载中");
    } else {
        ADVLog(@"百度 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_bd_ad load];
    }
}

- (void)showAd {
    [_bd_ad showFromViewController:_adspot.viewController];
    
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - expressFullVideoDelegate

- (void)fullScreenVideoAdLoaded:(BaiduMobAdExpressFullScreenVideo *)video {
//    ADVLog(@"百度全屏视频缓存成功");
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

- (void)fullScreenVideoAdLoadFailed:(BaiduMobAdExpressFullScreenVideo *)video withError:(BaiduMobFailReason)reason {
//    ADVLog(@"全屏视频缓存失败，failReason：%d", reason);
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
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
    NSLog(@"全屏视频点击跳过，progress:%f", progress);

}


@end
