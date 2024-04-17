//
//  KsRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "KsRenderFeedAdView.h"
#import "KsAdLogoView.h"

@interface KsRenderFeedAdView () <KSNativeAdDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;
@property (nonatomic, strong) KSNativeAd *nativeAd;
@property (nonatomic, strong) KSNativeAdRelatedView *nativeAdRelatedView;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) KsAdLogoView *adLogoView;

@end

@implementation KsRenderFeedAdView

- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedDelegate>)delegate
                          adSpot:(AdvanceRenderFeed *)adSpot
                        supplier:(AdvSupplier *)supplier {
    if (self = [super init]) {
        self.nativeAd = nativeAd;
        self.delegate = delegate;
        self.adSpot = adSpot;
        self.supplier = supplier;
        
        self.nativeAd.delegate = self;
        self.nativeAd.rootViewController = adSpot.viewController;
        self.nativeAdRelatedView = [KSNativeAdRelatedView new];
        [self.nativeAdRelatedView refreshData:self.nativeAd];
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    [self.nativeAd registerContainer:self withClickableViews:clickableViews containerClickable:NO];
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
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
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
    if (!self.nativeAdRelatedView.videoAdView.superview) {
        [self addSubview:self.nativeAdRelatedView.videoAdView];
    }
    return self.nativeAdRelatedView.videoAdView;
}

- (KsAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[KsAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - KSNativeAdDelegate

- (void)nativeAdDidLoad:(KSNativeAd *)nativeAd {
    
}

- (void)nativeAd:(KSNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeAdDidBecomeVisible:(KSNativeAd *)nativeAd {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdDidCloseOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidCloseDetailPageForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidCloseDetailPageForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdVideoPlayFinished:(KSNativeAd *)nativeAd {
    if ([self.delegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdVideoPlayError:(KSNativeAd *)nativeAd {
    
}

-(void)dealloc {
    
}

@end
