//
//  AdvKSRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvKSRenderFeedAdViewCreator.h"
#import "AdvKSAdLogoView.h"

@interface AdvKSRenderFeedAdViewCreator ()
@property (nonatomic, strong) KSNativeAdRelatedView *adView;
@property (nonatomic, strong) KSNativeAd *nativeAd;
@property (nonatomic, strong) AdvKSAdLogoView *adLogoView;

@end

@implementation AdvKSRenderFeedAdViewCreator

- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
                          adView:(KSNativeAdRelatedView *)adView {
    self = [super init];
    if (self) {
        _adView = adView;
        _nativeAd = nativeAd;
    }
    return self;
}

- (void)refreshData {
    [self.adView refreshData:self.nativeAd];
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.nativeAd registerContainer:containerView withClickableViews:clickableViews containerClickable:NO];
}

- (UIView *)logoImageView {
    return self.adLogoView;
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

- (UIView *)videoAdView {
    return self.adView.videoAdView;
}

- (AdvKSAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvKSAdLogoView alloc] init];
    }
    return _adLogoView;
}

@end
