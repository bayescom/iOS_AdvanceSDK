//
//  SigmobRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "SigmobRenderFeedAdView.h"
#import "SigmobAdLogoView.h"

@interface SigmobRenderFeedAdView () <WindNativeAdViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> adDelegate;
@property (nonatomic, strong) WindNativeAd *adDataObject;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) SigmobAdLogoView *adLogoView;

@end

@implementation SigmobRenderFeedAdView

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedDelegate>)delegate
                          adSpot:(AdvanceRenderFeed *)adSpot
                        supplier:(AdvSupplier *)supplier {
    if (self = [super init]) {
        self.adDataObject = nativeAd;
        self.adDelegate = delegate;
        self.adSpot = adSpot;
        self.supplier = supplier;
        
        self.delegate = self;
        self.viewController = adSpot.viewController;
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
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
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

- (SigmobAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[SigmobAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - WindNativeAdViewDelegate
/// 广告曝光回调
- (void)nativeAdViewWillExpose:(WindNativeAdView *)nativeAdView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

/// 广告点击回调
- (void)nativeAdViewDidClick:(WindNativeAdView *)nativeAdView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

@end
