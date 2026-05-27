//
//  AdvMercuryBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryBannerAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvMercuryBannerAdapter () <MercuryBannerAdViewDelegate, AdvanceCommonBannerAdapter>

@property (nonatomic, weak) id<AdvanceCommonBannerAdapterBridge> bridge;
@property (nonatomic, strong) MercuryBannerAdView *mercury_ad;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvMercuryBannerAdapter

- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _mercury_ad = [[MercuryBannerAdView alloc] initWithFrame:rect adspotId:placementId delegate:self];
    _mercury_ad.controller = config[kAdvanceAdPresentControllerKey];
    _mercury_ad.interval = 0; // 暂不支持刷新
    [_mercury_ad loadAdAndShow];
}

- (BOOL)adapter_isAdValid {
    return _mercury_ad.isAdValid;
}

- (UIView *)adapter_bannerView {
    return self.bannerView;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [_mercury_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - MercuryBannerAdViewDelegate
// 广告数据拉取成功回调
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *)banner {
    self.bannerView = banner;
    [self.bridge banner_didLoadAdWithAdapter:self price:banner.price];
}

// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(nullable NSError *)error {
    [self.bridge banner_failedToLoadAdWithAdapter:self error:error];
}

// 曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *)banner {
    [self.bridge banner_didAdExposuredWithAdapter:self];
}

// 渲染失败
- (void)mercury_bannerViewRenderFail:(MercuryBannerAdView *)banner error:(NSError *)error {
    [self.bridge banner_failedToShowAdWithAdapter:self error:error];
}

// 点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *)banner {
    [self.bridge banner_didAdClickedWithAdapter:self];
}

// 关闭回调
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *)banner {
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    [self.bridge banner_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
