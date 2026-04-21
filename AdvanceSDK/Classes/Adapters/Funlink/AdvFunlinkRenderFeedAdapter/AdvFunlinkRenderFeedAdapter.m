//
//  AdvFunlinkRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvFunlinkRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvFunlinkRenderFeedAdapter () <FLinkNativeDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) FLinkNativeManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvFunlinkRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
    _flink_ad = [[FLinkNativeManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.adCount = 1;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    _flink_ad.showAdController = config[kAdvanceAdPresentControllerKey];
}

- (void)adapter_loadAd {
    [_flink_ad loadAdData];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendWinNotificationWithSecondPrice:(NSInteger)secondPrice winPrice:(NSInteger)winPrice {
    [_flink_ad sendWinNotificationWithPrice:secondPrice];
}

- (void)adapter_sendLossNotificationWithFirstPrice:(NSInteger)firstPrice {
    [_flink_ad sendLossNotificationWithPrice:firstPrice];
}

#pragma mark: - FLinkNativeDelegate
- (void)nativeAdDidLoadDatas:(NSArray<__kindof FLinkFeedAdData *> *)datas {
    if (!datas.count) {
        NSError *error = [NSError errorWithDomain:@"FunlinkADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    FLinkFeedAdData *feedAdData = datas.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:feedAdData];
    AdvFunlinkRenderFeedAdView *flinkFeedAdView = [[AdvFunlinkRenderFeedAdView alloc] initWithAdData:feedAdData manager:self.flink_ad delegate:self.delegate adapterId:self.adapterId];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:flinkFeedAdView feedAdElement:element];
    
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)nativeAdDidFailed:(NSError *)error {
    [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
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
