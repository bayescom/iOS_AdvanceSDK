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
#import "AdvMercuryRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"

@interface AdvMercuryRenderFeedAdapter () <MercuryUnifiedNativeAdDelegate, AdvanceCommonRenderFeedAdapter>

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
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    AdvMercuryRenderFeedAdView *mercuryFeedAdView = [[AdvMercuryRenderFeedAdView alloc] initWithNativeAd:dataObject bridge:self.bridge adapter:self manager:nil viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:mercuryFeedAdView feedAdElement:element];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:dataObject.price];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.desc;
    element.iconUrl = dataObject.iconUrl;
    if (dataObject.isThreeImgsAd) { // 三图
        element.imageUrlList = dataObject.imageUrlList;
    } else if (dataObject.imageUrl.length) { // 单图
        element.imageUrlList = @[dataObject.imageUrl];
    }
    element.mediaWidth = dataObject.mediaWidth;
    element.mediaHeight = dataObject.mediaHeight;
    element.buttonText = dataObject.buttonText;
    element.isVideoAd = dataObject.isVideoAd;
    element.isAdValid = dataObject.isAdValid;
    return element;
}

- (void)dealloc {
    
}

@end
