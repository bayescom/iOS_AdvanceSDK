//
//  AdvGDTRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvGDTRenderFeedAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvGDTRenderFeedAdViewCreator.h"
#import "AdvGDTRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvGDTRenderFeedAdapter () <GDTUnifiedNativeAdDelegate, GDTUnifiedNativeAdViewDelegate, GDTMediaViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) GDTUnifiedNativeAd *gdt_ad;
@property (nonatomic, strong) GDTUnifiedNativeAdDataObject *dataObject;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvGDTRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _gdt_ad = [[GDTUnifiedNativeAd alloc] initWithPlacementId:placementId];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_dataObject sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [_dataObject sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}


#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
     
    GDTUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    self.dataObject = dataObject;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvGDTRenderFeedAdDataSource alloc] initWithDataObject:dataObject];
    GDTUnifiedNativeAdView *adView = [[GDTUnifiedNativeAdView alloc] init];
    adView.delegate = self;
    adView.viewController = self.rootViewController;
    if (dataSource.isVideoAd) {
        GDTVideoConfig *videoConfig = [[GDTVideoConfig alloc] init];
        videoConfig.videoMuted = YES;
        videoConfig.userControlEnable = YES;
        dataObject.videoConfig = videoConfig;
        adView.mediaView.delegate = self;
    }
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.view = adView;
    self.feedAdWrapper.viewCreator = [[AdvGDTRenderFeedAdViewCreator alloc] initWithDataObject:dataObject adView:adView];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:dataObject.eCPM];
}

#pragma mark - GDTUnifiedNativeAdViewDelegate
- (void)gdt_unifiedNativeAdViewDidClick:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)gdt_unifiedNativeAdViewWillExpose:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)gdt_unifiedNativeAdDetailViewClosed:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

- (void)gdt_unifiedNativeAdViewApplicationWillEnterBackground:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdDetailViewWillPresentScreen:(GDTUnifiedNativeAdView *)unifiedNativeAdView {
    
}

- (void)gdt_unifiedNativeAdView:(GDTUnifiedNativeAdView *)unifiedNativeAdView playerStatusChanged:(GDTMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    
}

#pragma mark - GDTMediaViewDelegate
- (void)gdt_mediaViewDidPlayFinished:(GDTMediaView *)mediaView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)gdt_mediaViewDidTapped:(GDTMediaView *)mediaView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
