//
//  GdtRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtRewardVideoAdapter.h"
#if __has_include(<GDTRewardVideoAd.h>)
#import <GDTRewardVideoAd.h>
#else
#import "GDTRewardVideoAd.h"
#endif
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"

@interface GdtRewardVideoAdapter () <GDTRewardedVideoAdDelegate>
@property (nonatomic, strong) GDTRewardVideoAd *gdt_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;

@end

@implementation GdtRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTRewardVideoAd alloc] initWithPlacementId:_supplier.adspotid];
        _gdt_ad.videoMuted = _adspot.muted;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载广点通 supplier: %@", _supplier);
    _gdt_ad.delegate = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_gdt_ad loadAd];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"广点通加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"广点通 成功");
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
    ADV_LEVEL_INFO_LOG(@"广点通 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    [_gdt_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (_gdt_ad) {
        _gdt_ad.delegate = nil;
        _gdt_ad = nil;
    }
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

// MARK: ======================= GdtRewardVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    _supplier.supplierPrice = rewardedVideoAd.eCPM;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    _supplier.state = AdvanceSdkSupplierStateSuccess;
//    NSLog(@"广点通激励视频拉取成功 %@",self.gdt_ad);
    if (_supplier.isParallel == YES) {
//        NSLog(@"修改状态: %@", _supplier);
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

/// 广告加载失败回调
- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }

//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

//视频缓存成功回调
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}

/// 视频广告曝光回调
- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 视频播放页关闭回调
- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 视频广告信息点击回调
- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 视频广告播放达到激励条件回调
//- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
//        [self.delegate advanceRewardVideoAdDidRewardEffective];
//    }
//}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd info:(NSDictionary *)info {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective:)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective:YES];
    }

}

/// 视频广告视频播放完成
- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}

@end
