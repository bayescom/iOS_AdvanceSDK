//
//  AdvBaiduRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "AdvBaiduRenderFeedAdView.h"
#import "AdvBaiduAdLogoView.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>

@interface AdvBaiduRenderFeedAdView () <BaiduMobAdNativeInterationDelegate, BaiduMobAdNativeVideoViewDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) BaiduMobAdNativeAdObject *adDataObject;
@property (nonatomic, strong) BaiduMobAdNativeVideoView *bdVideoView;
@property (nonatomic, strong) AdvBaiduAdLogoView *adLogoView;

@end

@implementation AdvBaiduRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(BaiduMobAdNativeAdObject *)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(id)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.adDataObject = nativeAd;
        self.bridge = bridge;
        self.adapter = adapter;
        
        self.adDataObject.interationDelegate = self;
    }
    return self;
}

- (void)registerClickableViews:(NSArray<UIView *> *)clickableViews andCloseableView:(UIView *)closeableView {
    
    /// 需要用BaiduMobAdNativeAdView进行渲染和曝光
    BaiduMobAdNativeAdView *nativeAdView = [[BaiduMobAdNativeAdView alloc] initWithFrame:self.bounds];
    [self insertSubview:nativeAdView atIndex:0];
    [self.adDataObject trackImpression:nativeAdView];
    
    if (_bdVideoView) {
        [_bdVideoView reSize];
        [_bdVideoView play];
    }
    if (clickableViews) {
        [self setupClickView:clickableViews];
    }
    if (closeableView) {
        [self setupCloseView:closeableView];
    }
}

- (CGSize)logoSize {
    return CGSizeMake(41, 14);
}

-(UIView *)logoImageView {
    if (!self.adLogoView.superview) {
        [self addSubview:self.adLogoView];
    }
    return self.adLogoView;
}

-(UIView *)videoAdView {
    if (!self.bdVideoView.videoDelegate) {
        self.bdVideoView.videoDelegate = self;
    }
    if (!self.bdVideoView.superview) {
        [self addSubview:self.bdVideoView];
    }
    return self.bdVideoView;
}

#pragma mark: - Actions
- (void)setupClickView:(NSArray<UIView *> *)clickableViews {
    [clickableViews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.userInteractionEnabled = YES;
        UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClickViewAction:)];
        [obj addGestureRecognizer:gr];
    }];
}

- (void)tapClickViewAction:(UITapGestureRecognizer *)gr {
    [self.adDataObject handleClick:gr.view];
}

- (void)setupCloseView:(UIView *)closeableView {
    closeableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseViewAction:)];
    [closeableView addGestureRecognizer:gr];
}

- (void)tapCloseViewAction:(UITapGestureRecognizer *)gr {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}

- (BaiduMobAdNativeVideoView *)bdVideoView {
    if (!_bdVideoView) {
        _bdVideoView = [[BaiduMobAdNativeVideoView alloc] initWithFrame:CGRectZero andObject:_adDataObject];
    }
    return _bdVideoView;
}

- (AdvBaiduAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[AdvBaiduAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - BaiduMobAdNativeInterationDelegate

/**
 *  广告曝光成功
 */
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

/**
 *  广告曝光失败
 */
- (void)nativeAdExposureFail:(UIView *)nativeAdView
          nativeAdDataObject:(BaiduMobAdNativeAdObject *)object
                  failReason:(int)reason {
    
}

/**
 *  广告点击
 */
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

/**
 *  广告详情页关闭
 */
- (void)didDismissLandingPage:(UIView *)nativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self.adapter];
}

#pragma mark - BaiduMobAdNativeVideoViewDelegate
/**
 视频播放完成
 */
- (void)nativeVideoAdDidComplete:(BaiduMobAdNativeVideoView *)videoView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
}

- (void)dealloc {
   
}

@end
