//
//  AdvFunlinkRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvFunlinkRenderFeedAdViewCreator.h"
#import "AdvFunlinkAdLogoView.h"

@interface AdvFunlinkRenderFeedAdViewCreator ()
@property (nonatomic, weak) FLinkNativeManager *manager;
@property (nonatomic, strong) FLinkFeedAdData *adData;
@property (nonatomic, strong) AdvFunlinkRenderFeedAdView *adView;
@property (nonatomic, strong) AdvFunlinkAdLogoView *adLogoView;

@end

@implementation AdvFunlinkRenderFeedAdViewCreator

- (instancetype)initWithManager:(FLinkNativeManager *)manager
                           data:(FLinkFeedAdData *)data
                         adView:(AdvFunlinkRenderFeedAdView *)adView {
    self = [super init];
    if (self) {
        _manager = manager;
        _adData = data;
        _adView = adView;
    }
    return self;
}

- (void)refreshData {
    self.adData.isCustomRender = YES;
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    self.adView.clickableViews = clickableViews;
    [self.manager registerAdForView:self.adView adData:self.adData];
}

- (UIView *)logoImageView {
    return self.adLogoView;
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

- (UIView *)videoAdView {
    return self.adData.mediaView;
}

- (AdvFunlinkAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvFunlinkAdLogoView alloc] initWithAdLogo:self.adData.adLogo];
    }
    return _adLogoView;
}

@end
