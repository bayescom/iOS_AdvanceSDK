//
//  AdvXXCustomRenderFeedAdViewCreator.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/18.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomRenderFeedAdViewCreator.h"

@interface AdvXXCustomRenderFeedAdViewCreator ()
@property (nonatomic, strong) BUNativeAdRelatedView *adView;
@property (nonatomic, strong) BUNativeAd *nativeAd;

@end

@implementation AdvXXCustomRenderFeedAdViewCreator

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
