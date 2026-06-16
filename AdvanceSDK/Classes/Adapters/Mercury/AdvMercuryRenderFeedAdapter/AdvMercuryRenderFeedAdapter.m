//
//  AdvMercuryRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "AdvMercuryRenderFeedAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvMercuryRenderFeedAdViewCreator.h"
#import "AdvMercuryRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvMercuryRenderFeedAdapter () <MercuryUnifiedNativeAdDelegate, MercuryUnifiedNativeAdViewDelegate, MercuryMediaViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) MercuryUnifiedNativeAd *mercury_ad;
@property (nonatomic, strong) MercuryUnifiedNativeAdDataObject *dataObject;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvMercuryRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _mercury_ad = [[MercuryUnifiedNativeAd alloc] initAdWithAdspotId:placementId delegate:self];
    [_mercury_ad loadAd];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [_dataObject sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark - MercuryUnifiedNativeAdDelegate
- (void)mercury_unifiedNativeAdLoaded:(NSArray<MercuryUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    MercuryUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    self.dataObject = dataObject;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvMercuryRenderFeedAdDataSource alloc] initWithDataObject:dataObject];
    MercuryUnifiedNativeAdView *adView = [[MercuryUnifiedNativeAdView alloc] init];
    adView.delegate = self;
    adView.viewController = self.rootViewController;
    if (dataSource.isVideoAd) {
        MercuryVideoConfig *videoConfig = [[MercuryVideoConfig alloc] init];
        videoConfig.videoMuted = YES;
        dataObject.videoConfig = videoConfig;
        adView.mediaView.delegate = self;
    }
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.view = adView;
    self.feedAdWrapper.viewCreator = [[AdvMercuryRenderFeedAdViewCreator alloc] initWithDataObject:dataObject adView:adView];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:dataObject.price];
}

#pragma mark - MercuryUnifiedNativeAdViewDelegate

/// 广告曝光回调
- (void)mercury_unifiedNativeAdViewWillExpose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

/// 广告点击回调
- (void)mercury_unifiedNativeAdViewDidClick:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

/// 广告关闭回调
- (void)mercury_unifiedNativeAdViewDidClose:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {

}

/// 广告详情页关闭回调
- (void)mercury_unifiedNativeAdDetailViewClosed:(MercuryUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

#pragma mark - MercuryMediaViewDelegate

- (void)mercury_mediaViewDidPlayFinish:(MercuryMediaView *)mediaView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
