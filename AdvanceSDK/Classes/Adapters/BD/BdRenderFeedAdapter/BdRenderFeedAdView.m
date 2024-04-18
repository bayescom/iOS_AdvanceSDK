//
//  BdRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "BdRenderFeedAdView.h"
#import <BaiduMobAdSDK/BaiduMobAdNativeAdView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeVideoView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeInterationDelegate.h>
#import "BdAdLogoView.h"

@interface BdRenderFeedAdView () <BaiduMobAdNativeInterationDelegate, BaiduMobAdNativeVideoViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> adDelegate;
@property (nonatomic, strong) BaiduMobAdNativeAdObject *adDataObject;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) BaiduMobAdNativeVideoView *bdVideoView;
@property (nonatomic, strong) BdAdLogoView *adLogoView;

@end

@implementation BdRenderFeedAdView

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject
                          delegate:(id<AdvanceRenderFeedDelegate>)delegate
                            adSpot:(AdvanceRenderFeed *)adSpot
                          supplier:(AdvSupplier *)supplier {
    
    if (self = [super init]) {
        self.adDataObject = dataObject;
        self.adDelegate = delegate;
        self.adSpot = adSpot;
        self.supplier = supplier;
        
        self.adDataObject.interationDelegate = self;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    
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
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
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

- (BaiduMobAdNativeVideoView *)bdVideoView {
    if (!_bdVideoView) {
        _bdVideoView = [[BaiduMobAdNativeVideoView alloc] initWithFrame:CGRectZero andObject:_adDataObject];
    }
    return _bdVideoView;
}

- (BdAdLogoView *)adLogoView {
    if (!_adLogoView) {
        _adLogoView = [[BdAdLogoView alloc] init];
    }
    return _adLogoView;
}

#pragma mark - BaiduMobAdNativeInterationDelegate

/**
 *  广告曝光成功
 */
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
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
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

/**
 *  广告详情页关闭
 */
- (void)didDismissLandingPage:(UIView *)nativeAdView {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseDetailPageForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseDetailPageForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

#pragma mark - BaiduMobAdNativeVideoViewDelegate
/**
 视频播放完成
 */
- (void)nativeVideoAdDidComplete:(BaiduMobAdNativeVideoView *)videoView {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.adDelegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)dealloc {
   
}

@end
