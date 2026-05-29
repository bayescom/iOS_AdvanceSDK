//
//  AdvTanxRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "AdvTanxRenderFeedAdView.h"
#import "AdvTanxAdLogoView.h"

@interface AdvTanxRenderFeedAdView () <TXAdFeedPlayerViewDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) TXAdFeedBinder *binder;
@property (nonatomic, strong) TXAdFeedPlayerView *tanxVideoView;
@property (nonatomic, strong) AdvTanxAdLogoView *adLogoView;

@end

@implementation AdvTanxRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(TXAdFeedBinder *)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(id)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.binder = nativeAd;
        self.bridge = bridge;
        self.adapter = adapter;
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

#pragma mark: - Actions
- (TXAdFeedPlayerView *)tanxVideoView {
    if (!_tanxVideoView) {
        TXAdFeedTemplateConfig *config =  [[TXAdFeedTemplateConfig alloc] init];
        _tanxVideoView = [_binder getVideoAdViewWithFrame:CGRectZero playConfig:config];
    }
    return _tanxVideoView;
}

- (AdvTanxAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvTanxAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark: - TXAdFeedManagerDelegate
- (void)onAdExposing:(TXAdModel *)model {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

- (void)onAdClick:(TXAdModel *)model clickView:(UIView *)clickView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

- (void)onAdClose:(TXAdModel *)model {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}

#pragma mark - TXAdFeedPlayerViewDelegate

// 视频播放完成回调
- (void)onVideoComplete {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
}

- (void)dealloc {
    
}
@end
