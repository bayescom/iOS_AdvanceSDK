//
//  AdvBiddingInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2023/3/27.
//

#import "AdvBiddingInterstitialAdapter.h"
#import "AdvPolicyModel.h"
#import "AdvanceInterstitial.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif
#import "AdvLog.h"

@interface AdvBiddingInterstitialAdapter ()<ABUInterstitialProAdDelegate>
@property (nonatomic, strong) ABUInterstitialProAd *interstitialAd;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isCached;

@end

@implementation AdvBiddingInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        
        self.interstitialAd = [[ABUInterstitialProAd alloc] initWithAdUnitID:_supplier.adspotid sizeForInterstitial:_adspot.adSize];
        self.interstitialAd.delegate = self;
        self.interstitialAd.mutedIfCan = _adspot.muted;

    }
    return self;
}


- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Bidding supplier: %@", _supplier);
    __weak typeof(self) _self = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    if([ABUAdSDKManager configDidLoad]) {
        //当前配置拉取成功，直接loadAdData
        [self.interstitialAd loadAdData];
    } else {
        //当前配置未拉取成功，在成功之后会调用该callback
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            __strong typeof(_self) self = _self;
            [self.interstitialAd loadAdData];
        }];
    }
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Bidding加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Bidding 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
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
    if (self.interstitialAd.isReady) {
        [self.interstitialAd showAdFromRootViewController:_adspot.viewController extraInfos:nil];
    }
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    self.interstitialAd.delegate = self;
    self.interstitialAd = nil;
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}
// Demo中定义的广告加载方法，在Demo中点击展示广告后触发该方法
- (void)showInterstitialProAd {
    [self.interstitialAd showAdFromRootViewController:self extraInfos:nil];
}

#pragma mark ----- ABUInterstitialProAdDelegate -----
/// 加载成功回调
- (void)interstitialProAdDidLoad:(ABUInterstitialProAd *)interstitialProAd {
    
}

- (void)interstitialProAdDidDownLoadVideo:(ABUInterstitialProAd *)interstitialProAd {
    //回调后再去展示广告，可保证播放和展示效果
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        if (_supplier.isParallel == YES) {
            return;
        }
        [self unifiedDelegate];
}

/// 加载失败回调
- (void)interstitialProAd:(ABUInterstitialProAd *)interstitialProAd didFailWithError:(NSError *)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }
    [self deallocAdapter];

}

/// 展示成功回调
- (void)interstitialProAdDidVisible:(ABUInterstitialProAd *)interstitialProAd {
    
    // 展示后可获取信息如下
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)interstitialProAdDidShowFailed:(ABUInterstitialProAd *)interstitialProAd error:(NSError *)error {
    
}

- (void)interstitialProAdDidPlayFinish:(ABUInterstitialProAd *)interstitialProAd didFailWithError:(NSError *)error {
    
}

/// 广告点击回调
- (void)interstitialProAdDidClick:(ABUInterstitialProAd *)interstitialProAd {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }

}

/// 广告关闭回调
- (void)interstitialProAdDidClose:(ABUInterstitialProAd *)interstitialProAd {
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

// 奖励验证回调
- (void)interstitialProAdServerRewardDidSucceed:(ABUInterstitialProAd *)interstitialProAd rewardInfo:(ABUAdapterRewardAdInfo *)rewardInfo verify:(BOOL)verify {
    
    // 验证信息
    ADV_LEVEL_INFO_LOG(@"verify: %@", verify ? @"YES" : @"NO");
    ADV_LEVEL_INFO_LOG(@"platform: %@", [interstitialProAd getShowEcpmInfo].adnName);
    ADV_LEVEL_INFO_LOG(@"reward name: %@", rewardInfo.rewardName);
    ADV_LEVEL_INFO_LOG(@"reward amount: %ld", rewardInfo.rewardAmount);
    ADV_LEVEL_INFO_LOG(@"trade id: %@", rewardInfo.tradeId ?: @"None");
}

#pragma mark ----- 可忽略 -----

//- (void)resetInterstitialProAd {
//    self.interstitialProAd.delegate = nil;
//    self.interstitialProAd = nil;
//}
//
//- (void)logAdInfoAfterShow {
//    // 展示后可获取信息如下
//    ABUD_Log(@"%@", [self.interstitialProAd getShowEcpmInfo]);
//}


- (void)unifiedDelegate {
    if (_isCached) {
        return;
    }
    _isCached = YES;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

@end
