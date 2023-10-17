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
#import "AdvLog.h"
#import "AdvanceBanner.h"
#import "AdvanceAdapter.h"

@interface CsjBannerAdapter () <BUNativeExpressBannerViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) BUNativeExpressBannerView *csj_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation CsjBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _csj_ad = [[BUNativeExpressBannerView alloc] initWithSlotID:_supplier.adspotid rootViewController:_adspot.viewController adSize:_adspot.adContainer.bounds.size interval:_adspot.refreshInterval];
        _csj_ad.frame = _adspot.adContainer.bounds;
        _csj_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_csj_ad loadAdData];
}

- (void)showAd {
    [_adspot.adContainer addSubview:_csj_ad];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingBannerADWithSpotId:)]) {
        [self.delegate didFinishLoadingBannerADWithSpotId:self.adspot.adspotid];
    }
}


// MARK: ======================= BUNativeExpressBannerViewDelegate =======================
/**
 *  广告数据拉取成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSDictionary *ext = bannerAdView.mediaExt;
    [self.adspot.manager setECPMIfNeeded:[ext[@"price"] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/**
 *  请求广告数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/**
 *  banner2.0曝光回调
 */
- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [self.csj_ad removeFromSuperview];
    self.csj_ad = nil;
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didCloseAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)dealloc {
    ADVLog(@"%s",__func__);
}

@end
