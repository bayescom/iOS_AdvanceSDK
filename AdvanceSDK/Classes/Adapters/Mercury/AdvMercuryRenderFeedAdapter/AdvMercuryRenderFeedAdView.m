//
//  AdvMercuryRenderFeedAdView.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "AdvMercuryRenderFeedAdView.h"

@interface AdvMercuryRenderFeedAdView () <MercuryUnifiedNativeAdViewDelegate, MercuryMediaViewDelegate>

@property (nonatomic, weak) id<AdvanceRenderFeedCommonAdapter> bridge;
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *adDataObject;
@property (nonatomic, copy) NSString *adapterId;

@end

@implementation AdvMercuryRenderFeedAdView

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject
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
    [self.bridge renderAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

/// 广告点击回调
- (void)mercury_unifiedNativeAdViewDidClick:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdClickedWithAdapterId:self.adapterId];
}

/// 广告关闭回调
- (void)mercury_unifiedNativeAdViewDidClose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdClosedWithAdapterId:self.adapterId];
}

/// 广告详情页关闭回调
- (void)mercury_unifiedNativeAdDetailViewClosed:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderAdapter_didAdClosedDetailPageWithAdapterId:self.adapterId];
}

#pragma mark - MercuryMediaViewDelegate

- (void)mercury_mediaViewDidPlayFinish:(MercuryMediaView *)mediaView {
    [self.bridge renderAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
