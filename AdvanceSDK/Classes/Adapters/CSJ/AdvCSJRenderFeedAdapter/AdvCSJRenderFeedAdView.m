//
//  AdvCSJRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import "AdvCSJRenderFeedAdView.h"

@interface AdvCSJRenderFeedAdView () <BUNativeAdDelegate, BUCustomEventProtocol, BUVideoAdViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) BUNativeAdRelatedView *nativeAdRelatedView;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvCSJRenderFeedAdView

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                       adapterId:(NSString *)adapterId
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.nativeAd = nativeAd;
        self.bridge = delegate;
        self.adapterId = adapterId;
        
        self.nativeAd.delegate = self;
        self.nativeAd.rootViewController = viewController;
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
    [self.bridge renderAdapter_didAdClosedWithAdapterId:self.adapterId];
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
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [self.bridge renderAdapter_didAdClosedDetailPageWithAdapterId:self.adapterId];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeAd:(BUNativeAd *)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    
}

#pragma mark - BUVideoAdViewDelegate
- (void)videoAdView:(BUMediaAdView *)adView stateDidChanged:(BUPlayerPlayState)playerState {
    
}

- (void)videoAdView:(BUMediaAdView *)adView didLoadFailWithError:(NSError *_Nullable)error {
    
}

- (void)playerDidPlayFinish:(BUMediaAdView *)adView {
    [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)videoAdViewDidClick:(BUMediaAdView *)adView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)videoAdViewFinishViewDidClick:(BUMediaAdView *)adView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)videoAdViewDidCloseOtherController:(BUMediaAdView *)adView interactionType:(BUInteractionType)interactionType {
    
}

- (void)videoAdView:(BUMediaAdView *)adView
 rewardDidCountDown:(NSInteger)countDown {
    
}

- (void)dealloc {
    
}

@end
