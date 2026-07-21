//
//  AdvNoahRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahRenderFeedAdViewCreator.h"
#import "AdvNoahAdLogoView.h"

@interface AdvNoahRenderFeedAdViewCreator ()
@property (nonatomic, strong) NativeAd *nativeAd;
@property (nonatomic, strong) AdvNoahAdLogoView *adLogoView;

@end

@implementation AdvNoahRenderFeedAdViewCreator

- (instancetype)initWithNativeAd:(NativeAd *)nativeAd {
    self = [super init];
    if (self) {
        _nativeAd = nativeAd;
    }
    return self;
}

- (void)refreshData {
    
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.nativeAd registerContainer:containerView clickableViews:clickableViews];
}

- (UIView *)logoImageView {
    return self.adLogoView;
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

- (UIView *)videoAdView {
    return self.nativeAd.getMediaView;
}

- (AdvNoahAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvNoahAdLogoView alloc] init];
    }
    return _adLogoView;
}

@end
