//
//  GroMoreSplashTrigger.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import "GroMoreSplashTrigger.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "GroMoreBiddingManager.h"

@interface GroMoreSplashTrigger () <ABUSplashAdDelegate>
/// gromore 广告位对象
@property (nonatomic, strong) ABUSplashAd *gmSplashAd;
/// advance 广告位对象 从最外层传递进来 负责 load and show
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) Gro_more *groMore;

@end

@implementation GroMoreSplashTrigger

- (instancetype)initWithGroMore:(Gro_more *)groMore adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _groMore = groMore;
        _gmSplashAd = [[ABUSplashAd alloc] initWithAdUnitID:groMore.gromore_params.adspotid];
        _gmSplashAd.delegate = self;
        _gmSplashAd.rootViewController = _adspot.viewController;
        _gmSplashAd.tolerateTimeout = groMore.gromore_params.timeout * 1.0 / 1000.0;
        _gmSplashAd.bidNotify = YES;
        [self setupBottomView];

    }
    return self;
}

// 设置logoView
- (void)setupBottomView {
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        UIImageView *bottomView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _adspot.logoImage.size.width, _adspot.logoImage.size.height)];
        bottomView.image = _adspot.logoImage;
        _gmSplashAd.customBottomView = bottomView;
    }
}

- (void)loadAd {
    if([ABUAdSDKManager configDidLoad]) {
        [self.gmSplashAd loadAdData];
    } else {
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            [self.gmSplashAd loadAdData];
        }];
    }
}

- (void)showInWindow:(UIWindow *)window {
    [_gmSplashAd showInWindow:window];
}

#pragma mark: - ABUSplashAdDelegate

- (void)splashAdDidLoad:(ABUSplashAd *)splashAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoSucceed groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (void)splashAd:(ABUSplashAd *)splashAd didFailWithError:(NSError *)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
    if ([self.delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [self.delegate didFailLoadingADSourceWithSpotId:self.adspot.adspotid error:error description:@{}];
    }
}

- (void)splashAdWillVisible:(ABUSplashAd *_Nonnull)splashAd {
    /// 广告曝光才能获取到竞价
    ABURitInfo *info = [splashAd getShowEcpmInfo];
    GroMoreBiddingManager.policyModel.gro_more.gromore_params.bidPrice = info.ecpm.integerValue;
    
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoImped groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)]) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdDidClick:(ABUSplashAd *)splashAd {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoClicked groMore:_groMore error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdDidClose:(ABUSplashAd *_Nonnull)splashAd {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)dealloc {
    [self.gmSplashAd destoryAd];
}

@end
