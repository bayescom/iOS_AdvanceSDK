//
//  MercuryRewardVideoAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryRewardVideoAdapter.h"
#if __has_include(<MercurySDK/MercuryRewardVideoAd.h>)
#import <MercurySDK/MercuryRewardVideoAd.h>
#else
#import "MercuryRewardVideoAd.h"
#endif
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"

@interface MercuryRewardVideoAdapter () <MercuryRewardVideoAdDelegate>
@property (nonatomic, strong) MercuryRewardVideoAd *mercury_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryRewardVideoAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercuryRewardVideoAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
        _mercury_ad.timeoutTime = 5;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Mercury supplier: %@", _supplier);
    [_mercury_ad loadRewardVideoAd];
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲Mercury...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Mercury 成功");
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"Mercury 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
    
}

- (void)showAd {
    [_mercury_ad showAdFromVC:_adspot.viewController];
}

- (void)deallocAdapter {
    _mercury_ad = nil;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= MercuryRewardVideoAdDelegate =======================
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
//        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

    _mercury_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceRewardVideoOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

//视频缓存成功回调
- (void)mercury_rewardVideoAdVideoDidLoad {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective];
    }
}

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}

@end
