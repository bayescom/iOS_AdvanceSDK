//
//  GdtBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtBannerAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceBanner.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface GdtBannerAdapter () <GDTUnifiedBannerViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) GDTUnifiedBannerView *gdt_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GdtBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _gdt_ad = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:_supplier.adspotid viewController:_adspot.viewController];
        _gdt_ad.animated = NO;
        _gdt_ad.autoSwitchInterval = _adspot.refreshInterval;
        _gdt_ad.delegate = self;

    }
    return self;
}

- (void)loadAd {
    [_gdt_ad loadAdAndShow];
}

- (void)showAd {
    [_adspot.adContainer addSubview:_gdt_ad];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingBannerADWithSpotId:)]) {
        [self.delegate didFinishLoadingBannerADWithSpotId:self.adspot.adspotid];
    }
}


// MARK: ======================= GDTUnifiedBannerViewDelegate =======================
/**
 *  广告数据拉取成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.adspot.manager setECPMIfNeeded:[unifiedBannerView eCPM] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

/**
 *  请求广告数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
    [_gdt_ad removeFromSuperview];
    _gdt_ad = nil;
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didCloseAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
        
    }
}

- (void)dealloc {
    ADVLog(@"%s",__func__);
}

@end
