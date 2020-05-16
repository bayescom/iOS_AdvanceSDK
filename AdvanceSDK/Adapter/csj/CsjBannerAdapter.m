//
//  CsjBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjBannerAdapter.h"

#if __has_include(<BUAdSDK/BUNativeExpressBannerView.h>)
#import <BUAdSDK/BUNativeExpressBannerView.h>
#else
#import "BUNativeExpressBannerView.h"
#endif

#import "AdvanceBanner.h"

@interface CsjBannerAdapter () <BUNativeExpressBannerViewDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *csj_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) NSDictionary *params;

@end

@implementation CsjBannerAdapter

- (instancetype)initWithParams:(NSDictionary *)params adspot:(AdvanceBanner *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    _csj_ad = [[BUNativeExpressBannerView alloc] initWithSlotID:_adspot.currentSdkSupplier.adspotid rootViewController:_adspot.viewController adSize:_adspot.adContainer.bounds.size IsSupportDeepLink:YES interval:_adspot.refreshInterval];
    _csj_ad.frame = _adspot.adContainer.bounds;
    _csj_ad.delegate = self;
    [_adspot.adContainer addSubview:_csj_ad];
    [_csj_ad loadAdData];
}

// MARK: ======================= BUNativeExpressBannerViewDelegate =======================
/**
 *  广告数据拉取成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdReceived)]) {
        [self.delegate advanceBannerOnAdReceived];
    }
}

/**
 *  请求广告数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    [self.adspot selectSdkSupplierWithError:error];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceBannerOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
}

/**
 *  banner2.0曝光回调
 */
- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdShow)]) {
        [self.delegate advanceBannerOnAdShow];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdClicked)]) {
        [self.delegate advanceBannerOnAdClicked];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [_csj_ad removeFromSuperview];
    _csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdClosed)]) {
        [self.delegate advanceBannerOnAdClosed];
    }
}

@end
