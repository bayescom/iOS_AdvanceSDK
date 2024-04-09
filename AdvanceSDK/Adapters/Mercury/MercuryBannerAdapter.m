//
//  MercuryBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryBannerAdapter.h"

#if __has_include(<MercurySDK/MercuryBannerAdView.h>)
#import <MercurySDK/MercuryBannerAdView.h>
#else
#import "MercuryBannerAdView.h"
#endif

#import "AdvanceBanner.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface MercuryBannerAdapter () <MercuryBannerAdViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) MercuryBannerAdView *mercury_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _mercury_ad = [[MercuryBannerAdView alloc] initWithFrame:rect adspotId:_adspot.adspotid delegate:self];
        _mercury_ad.controller = _adspot.viewController;
        _mercury_ad.interval = _adspot.refreshInterval;

    }
    return self;
}

- (void)loadAd {
    [_mercury_ad loadAdAndShow];
}

- (void)showAd {
    [_adspot.adContainer addSubview:_mercury_ad];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingBannerADWithSpotId:)]) {
        [self.delegate didFinishLoadingBannerADWithSpotId:self.adspot.adspotid];
    }
}

// MARK: ======================= MercuryBannerAdViewDelegate =======================
// 广告数据拉取成功回调
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *)banner {
    [self.adspot.manager setECPMIfNeeded:banner.price supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];

}

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(nullable NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

// 曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *)banner {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

// 点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *)banner {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

// 关闭回调
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *)banner {
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didCloseAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
        
    }
}

- (void)dealloc {
    ADVLog(@"%s",__func__);
}

@end
