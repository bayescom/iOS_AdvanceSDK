//
//  AdvTanxRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "AdvTanxRenderFeedAdView.h"
#import "AdvTanxAdLogoView.h"

@interface AdvTanxRenderFeedAdView () <TXAdFeedPlayerViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) TXAdFeedBinder *binder;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) TXAdFeedPlayerView *tanxVideoView;
@property (nonatomic, strong) AdvTanxAdLogoView *adLogoView;

@end

@implementation AdvTanxRenderFeedAdView

- (instancetype)initWithBinder:(TXAdFeedBinder *)binder
                      delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                     adapterId:(NSString *)adapterId {
    
    if (self = [super init]) {
        self.binder = binder;
        self.bridge = delegate;
        self.adapterId = adapterId;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews
              andCloseableView:(nullable UIView *)closeableView {
    [self.binder bindFeedView:self closeView:closeableView dislikeViews:nil];
    [self.binder registerFeedViewClickableViews:clickableViews];
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
    if (!self.tanxVideoView.delegate) {
        self.tanxVideoView.delegate = self;
    }
    if (!self.tanxVideoView.superview) {
        [self addSubview:self.tanxVideoView];
    }
    return self.tanxVideoView;
}

- (TXAdFeedPlayerView *)tanxVideoView {
    if (!_tanxVideoView) {
        TXAdFeedTemplateConfig *config =  [[TXAdFeedTemplateConfig alloc] init];
        _tanxVideoView = [_binder getVideoAdViewWithFrame:CGRectZero playConfig:config];
    }
    return _tanxVideoView;
}

- (AdvTanxAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvTanxAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark: - TXAdFeedManagerDelegate
- (void)onAdExposing:(TXAdModel *)model {
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)onAdClick:(TXAdModel *)model clickView:(UIView *)clickView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)onAdClose:(TXAdModel *)model {
    [self.bridge renderAdapter_didAdClosedWithAdapterId:self.adapterId];
}

#pragma mark - TXAdFeedPlayerViewDelegate

// 视频播放完成回调
- (void)onVideoComplete {
    [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}
@end
