//
//  AdvSigmobRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvSigmobRenderFeedAdViewCreator.h"
#import "AdvSigmobAdLogoView.h"

@interface AdvSigmobRenderFeedAdViewCreator ()
@property (nonatomic, strong) WindNativeAdView *adView;
@property (nonatomic, strong) WindNativeAd *nativeAd;
@property (nonatomic, strong) AdvSigmobAdLogoView *adLogoView;

@end

@implementation AdvSigmobRenderFeedAdViewCreator

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                          adView:(WindNativeAdView *)adView {
    self = [super init];
    if (self) {
        _adView = adView;
        _nativeAd = nativeAd;
    }
    return self;
}

- (void)refreshData {
    [self.adView refreshData:self.nativeAd];
    /// Bug:  logoView无法resetframe，只能autolayout更新位置
    [self.adView.logoView removeFromSuperview];
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.adView setClickableViews:clickableViews];
}

- (UIView *)logoImageView {
    return self.adLogoView;
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

- (UIView *)videoAdView {
    return self.adView.mediaView;
}

- (AdvSigmobAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvSigmobAdLogoView alloc] init];
    }
    return _adLogoView;
}

@end
