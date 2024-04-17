//
//  TanxRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "TanxRenderFeedAdView.h"
#import "TanxAdLogoView.h"

@interface TanxRenderFeedAdView () <TXAdFeedPlayerViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> adDelegate;
@property (nonatomic, strong) TXAdFeedBinder *binder;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) TXAdFeedPlayerView *tanxVideoView;
@property (nonatomic, strong) TanxAdLogoView *adLogoView;

@end

@implementation TanxRenderFeedAdView

- (instancetype)initWithBinder:(TXAdFeedBinder *)binder
                      delegate:(id<AdvanceRenderFeedDelegate>)delegate
                        adSpot:(AdvanceRenderFeed *)adSpot
                      supplier:(AdvSupplier *)supplier {
    
    if (self = [super init]) {
        self.binder = binder;
        self.adDelegate = delegate;
        self.adSpot = adSpot;
        self.supplier = supplier;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView {
    [self.binder bindFeedView:self closeView:closeableView dislikeViews:nil];
    [self.binder registerFeedViewClickableViews:clickableViews];
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

-(UIView *)logoImageView {
    if (!self.adLogoView.superview) {
        [self addSubview:self.adLogoView];
    }
    return self.adLogoView;
}

-(UIView *)videoAdView {
    if (!self.tanxVideoView.delegate) {
        self.tanxVideoView.delegate = self;
    }
    if (!self.tanxVideoView.superview) {
        [self addSubview:self.tanxVideoView];
    }
    return self.tanxVideoView;
}

- (TXAdFeedPlayerView *)tanxVideoView {
    if (!_tanxVideoView) {
        TXAdFeedTemplateConfig *config =  [[TXAdFeedTemplateConfig alloc] init];
        _tanxVideoView = [_binder getVideoAdViewWithFrame:CGRectZero playConfig:config];
    }
    return _tanxVideoView;
}

- (TanxAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[TanxAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark: - TXAdFeedManagerDelegate

- (void)onAdExposing:(TXAdModel *)model {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)onAdClick:(TXAdModel *)model clickView:(UIView *)clickView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)onAdClose:(TXAdModel *)model {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

#pragma mark - TXAdFeedPlayerViewDelegate

// 视频播放完成回调
- (void)onVideoComplete {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.adDelegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)dealloc {
    
}
@end
