//
//  AdvCSJRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/11.
//

#import "AdvCSJRenderFeedAdViewCreator.h"

@interface AdvCSJRenderFeedAdViewCreator ()
@property (nonatomic, strong) BUNativeAdRelatedView *adView;
@property (nonatomic, strong) BUNativeAd *nativeAd;

@end

@implementation AdvCSJRenderFeedAdViewCreator

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd adView:(BUNativeAdRelatedView *)adView {
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
    [self.nativeAd registerContainer:containerView withClickableViews:clickableViews];
}

- (UIView *)logoImageView {
    return self.adView.logoADImageView;
}

- (CGSize)logoSize {
    return CGSizeMake(45, 16);
}

- (UIView *)videoAdView {
    return self.adView.mediaAdView;
}

@end
