//
//  AdvBiddingRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/10.
//

#import "AdvBiddingRewardVideoAdapter.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvBiddingRewardVideoAdapter ()<ABURewardedVideoAdDelegate>
@property (nonatomic, strong) ABURewardedVideoAd *rewardedVideoAd;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;


@end

@implementation AdvBiddingRewardVideoAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        self.adspot = adspot;
        self.supplier = supplier;
        
        self.rewardedVideoAd = [[ABURewardedVideoAd alloc] initWithAdUnitID:_supplier.adspotid];
        // 如果需要场景，请设置该属性
        self.rewardedVideoAd.delegate = self;
        self.rewardedVideoAd.mutedIfCan = NO; //静音

    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Bidding supplier: %@", _supplier);
    __weak typeof(self) _self = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    if([ABUAdSDKManager configDidLoad]) {
        //当前配置拉取成功，直接loadAdData
        [self.rewardedVideoAd loadAdData];
    } else {
        //当前配置未拉取成功，在成功之后会调用该callback
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            __strong typeof(_self) self = _self;
            [self.rewardedVideoAd loadAdData];
        }];
    }
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Bidding加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Bidding 成功");
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
    ADV_LEVEL_INFO_LOG(@"Bidding 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    if (self.rewardedVideoAd.isReady) {
        [self.rewardedVideoAd showAdFromRootViewController:self.adspot.viewController];
    }
}

- (void)deallocAdapter {
    self.rewardedVideoAd = nil;
}


- (void)dealloc {
    ADVLog(@"%s", __func__);
}

/// 广告加载成功回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidLoad:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    
//    NSLog(@"Bidding激励视频拉取成功 %@",self.gdt_ad);
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
/// @param rewardedVideoAd 广告管理对象
/// @param error 错误信息
- (void)rewardedVideoAd:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd didFailWithError:(NSError *_Nullable)error {
    ADV_LEVEL_INFO_LOG(@"%s error:%@", __func__, error);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

}

/// 广告展示失败回调
/// @param rewardedVideoAd 广告管理对象
/// @param error 展示失败的原因
- (void)rewardedVideoAdDidShowFailed:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd error:(NSError *_Nonnull)error {
    ADV_LEVEL_INFO_LOG(@"%s error:%@", __func__, error);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
}

/// 广告已加载视频素材回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidDownLoadVideo:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    if (_supplier.isParallel == YES) {
        _isCached = YES;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoOnAdVideoCached)]) {
        [self.delegate advanceRewardVideoOnAdVideoCached];
    }
}

/// 广告展示回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidVisible:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    ABURitInfo *info = [rewardedVideoAd getShowEcpmInfo];
    ADV_LEVEL_INFO_LOG(@"ecpm:%@", info.ecpm);
    ADV_LEVEL_INFO_LOG(@"platform:%@", info.adnName);
    ADV_LEVEL_INFO_LOG(@"ritID:%@", info.slotID);
    ADV_LEVEL_INFO_LOG(@"requestID:%@", info.requestID ?: @"None");
    _supplier.supplierPrice = (info.ecpm) ? info.ecpm.integerValue : 0;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoGMBidding supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }

}

/// 广告关闭事件回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidClose:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 广告点击详情事件回调
/// @param rewardedVideoAd 广告管理对象
- (void)rewardedVideoAdDidClick:(ABURewardedVideoAd *_Nonnull)rewardedVideoAd {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 请求的服务器验证成功包括C2C和S2S方法回调
/// @param rewardedVideoAd 广告管理对象
/// @param rewardInfo 奖励发放验证信息
/// @param verify 是否验证通过
- (void)rewardedVideoAdServerRewardDidSucceed:(ABURewardedVideoAd *)rewardedVideoAd rewardInfo:(ABUAdapterRewardAdInfo *)rewardInfo verify:(BOOL)verify {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidRewardEffective:)]) {
        [self.delegate advanceRewardVideoAdDidRewardEffective:verify];
    }
}

- (void)rewardedVideoAd:(ABURewardedVideoAd *)rewardedVideoAd didPlayFinishWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(advanceRewardVideoAdDidPlayFinish)]) {
        [self.delegate advanceRewardVideoAdDidPlayFinish];
    }
}
@end
