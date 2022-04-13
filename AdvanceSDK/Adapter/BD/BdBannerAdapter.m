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

@interface BdBannerAdapter ()<BaiduMobAdViewDelegate>
@property (nonatomic, strong) BaiduMobAdView *bd_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end
@implementation BdBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
    }
    return self;
}

- (void)loadAd {
    
    CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
    _bd_ad = [[BaiduMobAdView alloc] init];
    _bd_ad.AdType = BaiduMobAdViewTypeBanner;
    _bd_ad.delegate = self;
    _bd_ad.AdUnitTag = _supplier.adspotid;
    _bd_ad.frame = rect;
    [_adspot.adContainer addSubview:_bd_ad];
    [_bd_ad start];

}

- (NSString *)publisherId {
    return  _supplier.mediaid; //@"your_own_app_id";
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000020 + reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
//    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceBannerOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
    [_bd_ad removeFromSuperview];
    _bd_ad = nil;
}

- (void)didAdImpressed {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

- (void)didAdClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

//点击关闭的时候移除广告
- (void)didAdClose {
//    [sharedAdView removeFromSuperview];
    [_bd_ad removeFromSuperview];
    _bd_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)didDismissLandingPage {
    
}
@end
