//
//  AdvFunlinkRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvFunlinkRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"

@interface AdvFunlinkRenderFeedAdapter () <FLinkNativeDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) FLinkNativeManager *flink_ad;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvFunlinkRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkNativeManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.adCount = 1;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    _flink_ad.showAdController = config[kAdvanceAdPresentControllerKey];
    [_flink_ad loadAdData];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_flink_ad sendWinNotificationWithPrice:result.secondPrice];
    } else {
        [_flink_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - FLinkNativeDelegate
- (void)nativeAdDidLoadDatas:(NSArray<__kindof FLinkFeedAdData *> *)datas {
    if (!datas.count) {
        NSError *error = [NSError errorWithDomain:@"FunlinkADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    FLinkFeedAdData *feedAdData = datas.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:feedAdData];
    AdvFunlinkRenderFeedAdView *flinkFeedAdView = [[AdvFunlinkRenderFeedAdView alloc] initWithNativeAd:feedAdData bridge:self.bridge adapter:self manager:self.flink_ad viewController:nil];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:flinkFeedAdView feedAdElement:element];
    
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:ecpm];
}

- (void)nativeAdDidFailed:(NSError *)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(FLinkFeedAdData *)feedAdData {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = feedAdData.adTitle;
    element.desc = feedAdData.adContent;
    element.iconUrl = feedAdData.iconUrl;
    if (feedAdData.imageUrl.length) {
        element.imageUrlList = @[feedAdData.imageUrl];
    } else if (feedAdData.mediaUrlList.count) {
        element.imageUrlList = feedAdData.mediaUrlList;
    }
    element.mediaWidth = feedAdData.imageWidth;
    element.mediaHeight = feedAdData.imageHeight;
    element.buttonText = feedAdData.buttonText;
    element.isVideoAd = feedAdData.isVideoAd;
    if (element.isVideoAd) {
        element.mediaWidth = feedAdData.videoWidth;
        element.mediaHeight = feedAdData.videoHeight;
    }
    element.videoDuration = feedAdData.videoDuration;
    element.isAdValid = self.flink_ad.getCurrentBaseEcpmInfo.isAdValid;
    return element;
}

- (void)dealloc {

}

@end
