//
//  BdBannerAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/28.
//

#import "BdBannerAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdView.h>)
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdView.h"
#endif
#import "AdvanceBanner.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface BdBannerAdapter ()<BaiduMobAdViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) BaiduMobAdView *bd_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation BdBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _bd_ad = [[BaiduMobAdView alloc] initWithFrame:rect];
        _bd_ad.AdType = BaiduMobAdViewTypeBanner;
        _bd_ad.delegate = self;
        _bd_ad.AdUnitTag = _supplier.adspotid;
    }
    return self;
}

- (void)loadAd {
    [_bd_ad start];
}

- (void)showAd {
    [_adspot.adContainer addSubview:_bd_ad];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingBannerADWithSpotId:)]) {
        [self.delegate didFinishLoadingBannerADWithSpotId:self.adspot.adspotid];
    }
}

// MARK: -BaiduMobAdViewDelegate

- (NSString *)publisherId {
    return  _supplier.mediaid;
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    [self.adspot.manager setECPMIfNeeded:0 supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000020 + reason userInfo:@{@"desc":@"百度横幅广告加载失败"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)didAdImpressed {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)didAdClicked {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)didAdClose {
    [_bd_ad removeFromSuperview];
    _bd_ad = nil;
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didCloseAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
        
    }
}

@end
