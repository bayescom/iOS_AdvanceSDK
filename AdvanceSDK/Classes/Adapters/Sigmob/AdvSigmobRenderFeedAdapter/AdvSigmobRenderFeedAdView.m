//
//  AdvSigmobRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "AdvSigmobRenderFeedAdView.h"
#import "AdvSigmobAdLogoView.h"

@interface AdvSigmobRenderFeedAdView () <WindNativeAdViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) WindNativeAd *adDataObject;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvSigmobAdLogoView *adLogoView;

@end

@implementation AdvSigmobRenderFeedAdView

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                       adapterId:(NSString *)adapterId
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.adDataObject = nativeAd;
        self.bridge = delegate;
        self.adapterId = adapterId;
        
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

- (void)setupCloseView:(UIView *)closeableView {
    closeableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseViewAction:)];
    [closeableView addGestureRecognizer:gr];
}

- (void)tapCloseViewAction:(UITapGestureRecognizer *)gr {
    [self.bridge renderAdapter_didAdClosedWithAdapterId:self.adapterId];
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

- (AdvSigmobAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvSigmobAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - WindNativeAdViewDelegate
/// 广告曝光回调
- (void)nativeAdViewWillExpose:(WindNativeAdView *)nativeAdView {
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

/// 广告点击回调
- (void)nativeAdViewDidClick:(WindNativeAdView *)nativeAdView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

/// 视频播放结束回调
- (void)nativeAdView:(WindNativeAdView *)nativeAdView playerStatusChanged:(WindMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    if (status == WindMediaPlayerStatusStoped) {
        [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
    }
}

@end
