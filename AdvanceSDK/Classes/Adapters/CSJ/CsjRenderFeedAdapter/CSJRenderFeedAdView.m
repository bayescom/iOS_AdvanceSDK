//
//  CSJRenderFeedAd.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import "CSJRenderFeedAdView.h"

@interface CSJRenderFeedAdView () <BUNativeAdDelegate, BUVideoAdViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> delegate;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdRelatedView *nativeAdRelatedView;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation CSJRenderFeedAdView

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd
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
        self.nativeAdRelatedView = [BUNativeAdRelatedView new];
        [self.nativeAdRelatedView refreshData:self.nativeAd];
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    [self.nativeAd registerContainer:self withClickableViews:clickableViews];
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
    return CGSizeMake(45, 16);
}

-(UIView *)logoImageView {
    if (!self.nativeAdRelatedView.logoADImageView.superview) {
        [self addSubview:self.nativeAdRelatedView.logoADImageView];
    }
    return self.nativeAdRelatedView.logoADImageView;
}

-(UIView *)videoAdView {
    if (!self.nativeAdRelatedView.mediaAdView.delegate) {
        self.nativeAdRelatedView.mediaAdView.delegate = self;
    }
    if (!self.nativeAdRelatedView.mediaAdView.superview) {
        [self addSubview:self.nativeAdRelatedView.mediaAdView];
    }
    return self.nativeAdRelatedView.mediaAdView;
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    
}
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd view:(UIView *)view {
    
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidCloseDetailPageForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidCloseDetailPageForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)nativeAd:(BUNativeAd *)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    
}

#pragma mark - BUVideoAdViewDelegate
- (void)videoAdView:(BUMediaAdView *)adView stateDidChanged:(BUPlayerPlayState)playerState {
    
}

- (void)videoAdView:(BUMediaAdView *)adView didLoadFailWithError:(NSError *_Nullable)error {
    
}

- (void)playerDidPlayFinish:(BUMediaAdView *)adView {
    if ([self.delegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)videoAdViewDidClick:(BUMediaAdView *)adView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)videoAdViewFinishViewDidClick:(BUMediaAdView *)adView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.delegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)videoAdViewDidCloseOtherController:(BUMediaAdView *)adView interactionType:(BUInteractionType)interactionType {
    
}

- (void)videoAdView:(BUMediaAdView *)adView
 rewardDidCountDown:(NSInteger)countDown {
    
}

- (void)dealloc {
    
}

@end
