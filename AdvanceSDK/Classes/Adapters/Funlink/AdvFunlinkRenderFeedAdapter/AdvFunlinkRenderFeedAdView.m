//
//  AdvFunlinkRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdView.h"
#import "AdvFunlinkAdLogoView.h"
#import <FLinkAdSaas/FLinkAdSaas.h>

@interface AdvFunlinkRenderFeedAdView () <FLinkNativeDelegate, FLinkNativeAdRenderProtocol>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, weak) FLinkNativeManager *manager;
@property (nonatomic, strong) FLinkFeedAdData *adData;
@property (nonatomic, strong) AdvFunlinkAdLogoView *adLogoView;
@property (nonatomic, strong) NSArray *clickableViews;

@end

@implementation AdvFunlinkRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(FLinkFeedAdData *)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(FLinkNativeManager *)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.adData = nativeAd;
        self.manager = manager;
        self.manager.delegate = self;
        self.bridge = bridge;
        self.adapter = adapter;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    self.clickableViews = clickableViews;
    self.adData.isCustomRender = YES;
    [self.manager registerAdForView:self adData:self.adData];
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
    if (!self.adData.mediaView.superview) {
        [self addSubview:self.adData.mediaView];
    }
    return self.adData.mediaView;
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

- (AdvFunlinkAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvFunlinkAdLogoView alloc] initWithAdLogo:self.adData.adLogo];
    }
    return _adLogoView;
}

#pragma mark - FLinkNativeAdRenderProtocol
// 广告主视图
- (UIView *)mainAdView {
    return self; // 决定可否曝光
}

// 广告图
- (UIImageView *)mainImageView {
    return nil;
}

// 可点击view的数组
- (NSArray *)clickViewArray {
    return self.clickableViews;
}

#pragma mark - FLinkNativeDelegate
- (void)nativeAdDidVisible {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

- (void)nativeAdDidClicked {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

- (void)nativeAdDidCloseWithADView:(UIView *)nativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self.adapter];
}


-(void)dealloc {
    
}

@end
