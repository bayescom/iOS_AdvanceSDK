//
//  TanxRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/15.
//

#import "TanxRewardVideoAdapter.h"
#if __has_include(<TanxSDK/TanxSDK.h>)
#import <TanxSDK/TanxSDK.h>
#else
#import "TanxSDK.h"
#endif

#import "AdvanceRewardVideo.h"
#import "AdvLog.h"

@interface TanxRewardVideoAdapter ()<TXAdRewardVideoAdDelegate>
@property (nonatomic, strong) TXAdRewardVideoAd *manager;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;


@end

@implementation TanxRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        self.manager = [[TXAdRewardVideoAd alloc] initWithPid:_supplier.adspotid];
        self.manager.delegate = self;
        self.manager.configuration.loadAdTimeoutInterval = 3;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Tanx supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self.manager loadAd];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Tanx加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Tanx 成功");
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
    ADV_LEVEL_INFO_LOG(@"Tanx 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    ADV_LEVEL_INFO_LOG(@"Tanx 展现");
    [self.manager uploadBiddingResult:YES];
    [self.manager showAdFromRootViewController:self.adspot.viewController configuration:[TXAdShowRewardVideoConfiguration new]];
}

- (void)deallocAdapter {

}


- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// 广告数据加载成功回调，此时视频可能正在缓存。
- (void)rewardVideoAdDidLoad:(TXAdRewardVideoAd *)rewardVideoAd {
    
    _supplier.supplierPrice = (rewardVideoAd.model.eCPM == nil) ? 0 : rewardVideoAd.model.eCPM.integerValue;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    
//    NSLog(@"广点通激励视频拉取成功 %@",self.gdt_ad);
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }

}

- (void)rewardVideoAdDidDownloadVideo:(TXAdRewardVideoAd *)rewardVideoAd {
    // 如果走缓存完成再播放的链路，在此回调之后展示激励视频
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}

/// 广告load失败回调
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didLoadFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
}

/// 视频下载失败回调，下载失败后会进行重试，该回调可能会被多次调用
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didDownloadFailWithError:(NSError *)error {
    
}

/// 广告弹出成功回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidShow:(TXAdRewardVideoAd *)rewardVideoAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 广告弹出出错回调
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didShowFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
}

/// 广告跳过回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidSkip:(TXAdRewardVideoAd *)rewardVideoAd {
    
}

/// 广告关闭回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidClose:(TXAdRewardVideoAd *)rewardVideoAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 激励视频播放完成或者出错
/// @param rewardVideoAd 广告管理对象
/// @param error nil 时代表成功
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didFinishPlayingWithError:(nullable NSError *)error {
    if (!error) {
        if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
            [self.delegate advanceRewardVideoAdDidPlayFinish];
        }
    }
}

/// 发奖回调
/// @param rewardVideoAd 广告管理对象
/// @param rewardInfo 发奖信息
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didReceiveRewardInfo:(TXAdRewardVideoRewardInfo *)rewardInfo {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective:)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective:rewardInfo.isValid];
    }
}

@end
