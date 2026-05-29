//
//  AdvGDTRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import "AdvGDTRenderFeedAdView.h"

@interface AdvGDTRenderFeedAdView () <GDTUnifiedNativeAdViewDelegate, GDTMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapter>adapter;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *adDataObject;

@end

@implementation AdvGDTRenderFeedAdView

#pragma mark: - AdvanceRenderFeedAdViewProtocol
- (instancetype)initWithNativeAd:(GDTUnifiedNativeAdDataObject *)nativeAd
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
    if ([self.adDataObject isVideoAd]) {
        GDTVideoConfig *videoConfig = [[GDTVideoConfig alloc] init];
        videoConfig.videoMuted = YES;
        videoConfig.userControlEnable = YES;
        self.adDataObject.videoConfig = videoConfig;
    }
    [super registerDataObject:self.adDataObject clickableViews:clickableViews];
    if (closeableView) {
        [self setupCloseView:closeableView];
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

#pragma mark: - Actions
- (void)setupCloseView:(UIView *)closeableView {
    closeableView.userInteractionEnabled = YES;
    UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapCloseViewAction:)];
    [closeableView addGestureRecognizer:gr];
}

- (void)tapCloseViewAction:(UITapGestureRecognizer *)gr {
    [self.bridge renderFeed_didAdClosedWithAdapter:self.adapter];
}



#pragma mark - GDTUnifiedNativeAdViewDelegate
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self.adapter];
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self.adapter];
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    
}

#pragma mark - GDTMediaViewDelegate
- (void)gdt_mediaViewDidPlayFinished:(GDTMediaView *)mediaView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self.adapter];
}

- (void)gdt_mediaViewDidTapped:(GDTMediaView *)mediaView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self.adapter];
}

-(void)dealloc {
    
}


@end
