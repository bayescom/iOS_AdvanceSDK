//
//  AdvSigmobRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "AdvSigmobRenderFeedAdView.h"
#import "AdvSigmobAdLogoView.h"

@interface AdvSigmobRenderFeedAdView () <WindNativeAdViewDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) AdvSigmobAdLogoView *adLogoView;

@end

@implementation AdvSigmobRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(id)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(id)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.bridge = bridge;
        self.adapter = adapter;
        
        self.delegate = self;
        self.viewController = viewController;
        [super refreshData:nativeAd];
        /// Bug:  logoView无法resetframe，只能autolayout更新位置
        [self.logoView removeFromSuperview];
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    [super setClickableViews:clickableViews];
    if (closeableView) {
        [self setupCloseView:closeableView];
    }
}

- (CGSize)logoSize {
    return CGSizeMake(43, 16);
}

- (UIView *)logoImageView {
    if (!self.adLogoView.superview) {
        [self addSubview:self.adLogoView];
    }
    return self.adLogoView;
}

-(UIView *)videoAdView {
    return self.mediaView;
}

#pragma mark - Actions
- (void)setupCloseView:(UIView *)closeableView {
    closeableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseViewAction:)];
    [closeableView addGestureRecognizer:gr];
}

- (void)tapCloseViewAction:(UITapGestureRecognizer *)gr {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}

- (AdvSigmobAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvSigmobAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - WindNativeAdViewDelegate
/// 广告曝光回调
- (void)nativeAdViewWillExpose:(WindNativeAdView *)nativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

/// 广告点击回调
- (void)nativeAdViewDidClick:(WindNativeAdView *)nativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

/// 视频播放结束回调
- (void)nativeAdView:(WindNativeAdView *)nativeAdView playerStatusChanged:(WindMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    if (status == WindMediaPlayerStatusStoped) {
        [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
    }
}

@end
