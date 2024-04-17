//
//  MercuryRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "MercuryRenderFeedAdView.h"

@interface MercuryRenderFeedAdView () <MercuryUnifiedNativeAdViewDelegate, MercuryMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> adDelegate;
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *adDataObject;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryRenderFeedAdView

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject
                          delegate:(id<AdvanceRenderFeedDelegate>)delegate
                            adSpot:(AdvanceRenderFeed *)adSpot
                          supplier:(AdvSupplier *)supplier {
    
    if (self = [super init]) {
        self.adDataObject = dataObject;
        self.adDelegate = delegate;
        self.adSpot = adSpot;
        self.supplier = supplier;
        
        self.delegate = self;
        self.viewController = adSpot.viewController;
    }
    return self;
}

- (void)registerClickableViews:(nullable NSArray<UIView *> *)clickableViews andCloseableView:(nullable UIView *)closeableView {
    MercuryVideoConfig *videoConfig = [[MercuryVideoConfig alloc] init];
    self.adDataObject.videoConfig = videoConfig;
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
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

/// 广告点击回调
- (void)mercury_unifiedNativeAdViewDidClick:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

/// 广告关闭回调
- (void)mercury_unifiedNativeAdViewDidClose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

/// 广告详情页关闭回调
- (void)mercury_unifiedNativeAdDetailViewClosed:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseDetailPageForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseDetailPageForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

#pragma mark - MercuryMediaViewDelegate

- (void)mercury_mediaViewDidPlayFinish:(MercuryMediaView *)mediaView {
    if ([self.adDelegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.adDelegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)dealloc {
    
}

@end
