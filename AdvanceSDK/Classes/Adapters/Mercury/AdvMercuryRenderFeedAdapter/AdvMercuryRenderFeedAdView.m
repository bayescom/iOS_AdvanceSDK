//
//  AdvMercuryRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "AdvMercuryRenderFeedAdView.h"

@interface AdvMercuryRenderFeedAdView () <MercuryUnifiedNativeAdViewDelegate, MercuryMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *adDataObject;

@end

@implementation AdvMercuryRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(MercuryUnifiedNativeAdDataObject *)nativeAd
                          bridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge
                         adapter:(id<AdvanceCommonRenderFeedAdapter>)adapter
                         manager:(id)manager
                  viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.adDataObject = nativeAd;
        self.bridge = bridge;
        self.adapter = adapter;
        
        self.delegate = self;
        self.viewController = viewController;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    if (self.dataObject.isVideoAd) {
        MercuryVideoConfig *videoConfig = [[MercuryVideoConfig alloc] init];
        self.adDataObject.videoConfig = videoConfig;
    }
    [super registerDataObject:self.dataObject clickableViews:clickableViews closeableViews:@[closeableView]];
}

- (CGSize)logoSize {
    if (!self.dataObject.logoUrl.length) {
        return CGSizeMake(25, 15);
    }
    return CGSizeMake(40, 15);
}

-(UIView *)logoImageView {
    return self.logoView;
}

-(UIView *)videoAdView {
    if (!self.mediaView.delegate) {
        self.mediaView.delegate = self;
    }
    return self.mediaView;
}

#pragma mark - MercuryUnifiedNativeAdViewDelegate

/// 广告曝光回调
- (void)mercury_unifiedNativeAdViewWillExpose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

/// 广告点击回调
- (void)mercury_unifiedNativeAdViewDidClick:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

/// 广告关闭回调
- (void)mercury_unifiedNativeAdViewDidClose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}

/// 广告详情页关闭回调
- (void)mercury_unifiedNativeAdDetailViewClosed:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self.adapter];
}

#pragma mark - MercuryMediaViewDelegate

- (void)mercury_mediaViewDidPlayFinish:(MercuryMediaView *)mediaView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
}

- (void)dealloc {
    
}

@end
