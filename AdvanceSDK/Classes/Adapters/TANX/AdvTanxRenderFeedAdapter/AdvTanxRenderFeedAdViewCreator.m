//
//  AdvTanxRenderFeedAdViewCreator.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import "AdvTanxRenderFeedAdViewCreator.h"
#import "AdvTanxAdLogoView.h"

@interface AdvTanxRenderFeedAdViewCreator ()
@property (nonatomic, strong) TXAdFeedBinder *binder;
@property (nonatomic, strong) TXAdFeedView *adView;
@property (nonatomic, strong) TXAdFeedPlayerView *tanxVideoView;
@property (nonatomic, strong) AdvTanxAdLogoView *adLogoView;

@end

@implementation AdvTanxRenderFeedAdViewCreator

- (instancetype)initWithBinder:(TXAdFeedBinder *)binder
                        adView:(TXAdFeedView *)adView
                     videoView:(TXAdFeedPlayerView *)videoView {
    self = [super init];
    if (self) {
        _binder = binder;
        _adView = adView;
        _tanxVideoView = videoView;
    }
    return self;
}

- (void)refreshData {
    [self.binder bindFeedView:self.adView closeView:nil dislikeViews:nil];
}

- (void)registerContainer:(UIView *)containerView withClickableViews:(NSArray<UIView *> *)clickableViews {
    [self.binder registerFeedViewClickableViews:clickableViews];
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

-(UIView *)logoImageView {
    return self.adLogoView;
}

-(UIView *)videoAdView {
    return self.tanxVideoView;
}

- (AdvTanxAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvTanxAdLogoView alloc] init];
    }
    return _adLogoView;
}

@end
