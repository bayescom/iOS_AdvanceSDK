//
//  AdvGDTRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/11.
//

#import "AdvGDTRenderFeedAdView.h"

@interface AdvGDTRenderFeedAdView () <GDTUnifiedNativeAdViewDelegate, GDTMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *adDataObject;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvGDTRenderFeedAdView

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject
                          delegate:(id<AdvanceRenderFeedCommonAdapter>)delegate
                         adapterId:(NSString *)adapterId
                    viewController:(UIViewController *)viewController {
    if (self = [super init]) {
        self.adDataObject = dataObject;
        self.bridge = delegate;
        self.adapterId = adapterId;
        
        self.delegate = self;
        self.viewController = viewController;
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
    [self.bridge renderAdapter_didAdClosedWithAdapterId:self.adapterId];
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
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdClosedDetailPageWithAdapterId:self.adapterId];
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    
}

#pragma mark - GDTMediaViewDelegate
- (void)gdt_mediaViewDidPlayFinished:(GDTMediaView *)mediaView {
    [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)gdt_mediaViewDidTapped:(GDTMediaView *)mediaView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

-(void)dealloc {
    
}


@end
