//
//  BdRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/27.
//

#import "BdRewardVideoAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdRewardVideo.h>)
#import <BaiduMobAdSDK/BaiduMobAdRewardVideo.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdRewardVideo.h"
#endif
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
@interface BdRewardVideoAdapter ()<BaiduMobAdRewardVideoDelegate>
@property (nonatomic, strong) BaiduMobAdRewardVideo *bd_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;

@end

@implementation BdRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdRewardVideo alloc] init];
        _bd_ad.delegate = self;
        _bd_ad.AdUnitTag = _supplier.adspotid;
        _bd_ad.publisherId = _supplier.mediaid;
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
        if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
            [self.delegate advanceRewardVideoOnAdVideoCached];
        }
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
}

- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    [_bd_ad showFromViewController:_adspot.viewController];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (_bd_ad) {
        _bd_ad.delegate = nil;
        _bd_ad = nil;
    }
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

- (void)rewardedAdLoadSuccess:(BaiduMobAdRewardVideo *)video {
    //    NSLog(@"激励视频请求成功");
    _supplier.supplierPrice = [[video getECPMLevel] integerValue];
//    _supplier.supplierPrice = 10;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }

}

- (void)rewardedAdLoadFail:(BaiduMobAdRewardVideo *)video {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000000 userInfo:@{@"desc":@"百度广告请求错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }
}

- (void)rewardedVideoAdLoaded:(BaiduMobAdRewardVideo *)video {
//    NSLog(@"激励视频缓存成功");
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
    
}

- (void)rewardedVideoAdLoadFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000010 + reason userInfo:@{@"desc":@"百度广告缓存错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    NSLog(@"激励视频缓存失败，failReason：%d", reason);
}

- (void)rewardedVideoAdShowFailed:(BaiduMobAdRewardVideo *)video withError:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000020 + reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    NSLog(@"激励视频展现失败，failReason：%d", reason);
    //异常情况处理
}

- (void)rewardedVideoAdDidStarted:(BaiduMobAdRewardVideo *)video {
//    NSLog(@"激励视频开始播放");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }

}

- (void)rewardedVideoAdDidPlayFinish:(BaiduMobAdRewardVideo *)video {
    
//    NSLog(@"激励视频完成播放");
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }

}

- (void)rewardedVideoAdDidClick:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"激励视频被点击，progress:%f", progress);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)rewardedVideoAdDidClose:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"激励视频点击关闭，progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)rewardedVideoAdDidSkip:(BaiduMobAdRewardVideo *)video withPlayingProgress:(CGFloat)progress {
//    NSLog(@"激励视频点击跳过, progress:%f", progress);
}

- (void)rewardedVideoAdRewardDidSuccess:(BaiduMobAdRewardVideo *)video verify:(BOOL)verify {
    //    NSLog(@"激励成功回调, progress:%f", progress);
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective:)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective:verify];
    }
}


@end
