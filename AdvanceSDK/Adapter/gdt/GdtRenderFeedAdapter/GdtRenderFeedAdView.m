//
//  GdtRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import "GdtRenderFeedAdView.h"

@interface GdtRenderFeedAdView () <GDTUnifiedNativeAdViewDelegate, GDTMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedDelegate> adDelegate;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *adDataObject;
@property (nonatomic, weak) AdvanceRenderFeed *adSpot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GdtRenderFeedAdView

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject
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
    if ([self.adDataObject isAdValid]) {
        GDTVideoConfig *videoConfig = [[GDTVideoConfig alloc] init];
        videoConfig.videoMuted = YES;
        videoConfig.userControlEnable = YES;
        self.adDataObject.videoConfig = videoConfig;
        [super registerDataObject:self.adDataObject clickableViews:clickableViews];
    }
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
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (CGSize)logoSize {
    return CGSizeMake(kGDTLogoImageViewDefaultWidth, kGDTLogoImageViewDefaultHeight);
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


#pragma mark - GDTUnifiedNativeAdViewDelegate
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    [self.adSpot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidShowForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidShowForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidCloseDetailPageForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidCloseDetailPageForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView
{
    
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo
{
    
}

#pragma mark - GDTMediaViewDelegate
- (void)gdt_mediaViewDidPlayFinished:(GDTMediaView *)mediaView
{
    if ([self.adDelegate respondsToSelector:@selector(renderFeedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.adDelegate renderFeedVideoDidEndPlayingForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

- (void)gdt_mediaViewDidTapped:(GDTMediaView *)mediaView
{
    if ([self.adDelegate respondsToSelector:@selector(renderFeedAdDidClickForSpotId:extra:)]) {
        [self.adDelegate renderFeedAdDidClickForSpotId:self.adSpot.adspotid extra:self.adSpot.ext];
    }
}

-(void)dealloc {
    
}


@end
