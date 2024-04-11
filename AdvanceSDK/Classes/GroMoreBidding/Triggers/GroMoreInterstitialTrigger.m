//
//  GroMoreInterstitialTrigger.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import "GroMoreInterstitialTrigger.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import "AdvanceInterstitial.h"
#import "AdvLog.h"
#import "GroMoreBiddingManager.h"

@interface GroMoreInterstitialTrigger () <ABUInterstitialProAdDelegate>
/// gromore 广告位对象
@property (nonatomic, strong) ABUInterstitialProAd *gmInterstitialAd;
/// advance 广告位对象 从最外层传递进来 负责 load and show
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) Gro_more *groMore;

@end

@implementation GroMoreInterstitialTrigger

- (instancetype)initWithGroMore:(Gro_more *)groMore adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _groMore = groMore;
        _gmInterstitialAd = [[ABUInterstitialProAd alloc] initWithAdUnitID:groMore.gromore_params.adspotid sizeForInterstitial:CGSizeZero];
        _gmInterstitialAd.delegate = self;
        _gmInterstitialAd.mutedIfCan = _adspot.muted;
        _gmInterstitialAd.bidNotify = YES;
    }
    return self;
}

- (void)loadAd {
    if([ABUAdSDKManager configDidLoad]) {
        [self.gmInterstitialAd loadAdData];
    } else {
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            [self.gmInterstitialAd loadAdData];
        }];
    }
}

- (void)showAd {
    if (self.gmInterstitialAd.isReady) {
        [self.gmInterstitialAd showAdFromRootViewController:self.adspot.viewController extraInfos:nil];
    }
}

#pragma mark: - ABUInterstitialProAdDelegate

/// 加载成功回调
- (void)interstitialProAdDidLoad:(ABUInterstitialProAd *)interstitialProAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoSucceed groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

/// 加载失败回调
- (void)interstitialProAd:(ABUInterstitialProAd *)interstitialProAd didFailWithError:(NSError *)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
    if ([self.delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [self.delegate didFailLoadingADSourceWithSpotId:self.adspot.adspotid error:error description:@{}];
    }
}

/// 展示成功回调
- (void)interstitialProAdDidVisible:(ABUInterstitialProAd *)interstitialProAd {
    /// 广告曝光才能获取到竞价
    ABURitInfo *info = [interstitialProAd getShowEcpmInfo];
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoImped groMore:_groMore error:nil];
    
    GroMoreBiddingManager.policyModel.gro_more.gromore_params.bidPrice = info.ecpm.integerValue;
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/// 广告点击回调
- (void)interstitialProAdDidClick:(ABUInterstitialProAd *)interstitialProAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoClicked groMore:_groMore error:nil];
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

@end
