//
//  KsRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "AdvKSRenderFeedAdView.h"
#import "AdvKSAdLogoView.h"

@interface AdvKSRenderFeedAdView () <KSNativeAdDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) KSNativeAd *nativeAd;
@property (nonatomic, strong) KSNativeAdRelatedView *nativeAdRelatedView;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvKSAdLogoView *adLogoView;

@end

@implementation AdvKSRenderFeedAdView

- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
                        delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                       adapterId:(NSString *)adapterId
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.nativeAd = nativeAd;
        self.bridge = delegate;
        self.adapterId = adapterId;
        
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
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeAdDidCloseOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    [self.bridge renderAdapter_didAdClosedDetailPageWithAdapterId:self.adapterId];
}

- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeAdVideoPlayFinished:(KSNativeAd *)nativeAd {
    [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)nativeAdVideoPlayError:(KSNativeAd *)nativeAd {
    
}

-(void)dealloc {
    
}

@end
