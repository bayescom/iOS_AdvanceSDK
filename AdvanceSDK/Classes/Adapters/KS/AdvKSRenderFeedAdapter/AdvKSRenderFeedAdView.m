//
//  KsRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "AdvKSRenderFeedAdView.h"
#import "AdvKSAdLogoView.h"
#import <KSAdSDK/KSAdSDK.h>

@interface AdvKSRenderFeedAdView () <KSNativeAdDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) KSNativeAd *nativeAd;
@property (nonatomic, strong) KSNativeAdRelatedView *nativeAdRelatedView;
@property (nonatomic, strong) AdvKSAdLogoView *adLogoView;

@end

@implementation AdvKSRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(id)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.nativeAd = nativeAd;
        self.bridge = bridge;
        self.adapter = adapter;
        
        self.nativeAd.delegate = self;
        self.nativeAd.rootViewController = viewController;
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

#pragma mark: - Actions
- (void)setupCloseView:(UIView *)closeableView {
    closeableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseViewAction:)];
    [closeableView addGestureRecognizer:gr];
}

- (void)tapCloseViewAction:(UITapGestureRecognizer *)gr {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}


- (AdvKSAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvKSAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - KSNativeAdDelegate

- (void)nativeAdDidLoad:(KSNativeAd *)nativeAd {
    
}

- (void)nativeAd:(KSNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeAdDidBecomeVisible:(KSNativeAd *)nativeAd {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

- (void)nativeAdDidCloseOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self.adapter];
}

- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

- (void)nativeAdVideoPlayFinished:(KSNativeAd *)nativeAd {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
}

- (void)nativeAdVideoPlayError:(KSNativeAd *)nativeAd {
    
}

-(void)dealloc {
    
}

@end
