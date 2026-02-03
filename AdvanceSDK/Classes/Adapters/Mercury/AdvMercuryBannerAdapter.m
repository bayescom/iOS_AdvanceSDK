//
//  AdvMercuryBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryBannerAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceBannerCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvMercuryBannerAdapter () <MercuryBannerAdViewDelegate, AdvanceBannerCommonAdapter>
@property (nonatomic, strong) MercuryBannerAdView *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvMercuryBannerAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _mercury_ad = [[MercuryBannerAdView alloc] initWithFrame:rect adspotId:placementId delegate:self];
    _mercury_ad.controller = config[kAdvanceAdPresentControllerKey];
    _mercury_ad.interval = 0; // 暂不支持刷新
}

- (void)adapter_loadAd {
    [_mercury_ad loadAdAndShow];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = [_mercury_ad performSelector:@selector(isAdValid)];
    if (!valid) {
        [self.delegate bannerAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (id)adapter_bannerView {
    return self.bannerView;
}

#pragma mark: - MercuryBannerAdViewDelegate
// 广告数据拉取成功回调
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *)banner {
    self.bannerView = banner;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:banner.price];
    [self.delegate bannerAdapter_didLoadAdWithAdapterId:self.adapterId price:banner.price];
}

// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(nullable NSError *)error {
    [self.delegate bannerAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

// 曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *)banner {
    [self.delegate bannerAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

// 渲染失败
- (void)mercury_bannerViewRenderFail:(MercuryBannerAdView *)banner error:(NSError *)error {
    [self.delegate bannerAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

// 点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *)banner {
    [self.delegate bannerAdapter_didAdClickedWithAdapterId:self.adapterId];
}

// 关闭回调
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *)banner {
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    [self.delegate bannerAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
