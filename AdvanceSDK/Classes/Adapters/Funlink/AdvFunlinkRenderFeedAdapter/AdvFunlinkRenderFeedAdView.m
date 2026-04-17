//
//  AdvFunlinkRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdView.h"
#import "AdvFunlinkAdLogoView.h"

@interface AdvFunlinkRenderFeedAdView () <FLinkNativeDelegate, FLinkNativeAdRenderProtocol>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, weak) FLinkNativeManager *manager;
@property (nonatomic, strong) FLinkFeedAdData *adData;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvFunlinkAdLogoView *adLogoView;
@property (nonatomic, strong) NSArray *clickableViews;

@end

@implementation AdvFunlinkRenderFeedAdView

- (instancetype)initWithAdData:(FLinkFeedAdData*)data
                       manager:(FLinkNativeManager *)manager
                      delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                     adapterId:(NSString *)adapterId {
    if (self = [super init]) {
        self.adData = data;
        self.manager = manager;
        self.manager.delegate = self;
        self.bridge = delegate;
        self.adapterId = adapterId;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    self.clickableViews = clickableViews;
    [self.manager registerAdForView:self adData:self.adData];
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
    if (!self.adData.mediaView.superview) {
        [self addSubview:self.adData.mediaView];
    }
    return self.adData.mediaView;
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
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeAdDidClicked {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeAdDidCloseWithADView:(UIView *)nativeAdView {
    [self.bridge renderAdapter_didAdClosedDetailPageWithAdapterId:self.adapterId];
}


-(void)dealloc {
    
}

@end
