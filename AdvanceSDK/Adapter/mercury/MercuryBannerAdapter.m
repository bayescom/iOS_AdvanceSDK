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

@interface MercuryBannerAdapter () <MercuryBannerAdViewDelegate>
@property (nonatomic, strong) MercuryBannerAdView *mercury_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceBanner *adspot;

@end

@implementation MercuryBannerAdapter

- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceBanner *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
    _mercury_ad = [[MercuryBannerAdView alloc] initWithFrame:rect adspotId:_adspot.currentSdkSupplier.adspotid delegate:self];
    _mercury_ad.controller = _adspot.viewController;
    _mercury_ad.animationOn = YES;
    _mercury_ad.showCloseBtn = YES;
    _mercury_ad.interval = _adspot.refreshInterval;
    [_adspot.adContainer addSubview:_mercury_ad];
    [_mercury_ad loadAdAndShow];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= MercuryBannerAdViewDelegate =======================
// 广告数据拉取成功回调
- (void)mercury_bannerViewDidReceived {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdReceived)]) {
        [self.delegate advanceBannerOnAdReceived];
    }
}

// 请求广告数据失败后调用
- (void)mercury_bannerViewFailToReceived:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceBannerOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

// 曝光回调
- (void)mercury_bannerViewWillExposure {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdShow)]) {
        [self.delegate advanceBannerOnAdShow];
    }
}

// 点击回调
- (void)mercury_bannerViewClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdClicked)]) {
        [self.delegate advanceBannerOnAdClicked];
    }
}

// 关闭回调
- (void)mercury_bannerViewWillClose {
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdClosed)]) {
        [self.delegate advanceBannerOnAdClosed];
    }
}

@end
