//
//  AdvBaiduRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "AdvBaiduRenderFeedAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvBaiduRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"

@interface AdvBaiduRenderFeedAdapter () <BaiduMobAdNativeAdDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, strong) BaiduMobAdNativeAdObject *dataObject;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvBaiduRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bd_ad = [[BaiduMobAdNative alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.adDelegate = self;
    _bd_ad.presentAdViewController = config[kAdvanceAdPresentControllerKey];
    [_bd_ad load];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.dataObject biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    } else {
        [self.dataObject biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    }
}


#pragma mark - BaiduMobAdNativeAdDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    BaiduMobAdNativeAdObject *dataObject = nativeAds.firstObject;
    self.dataObject = dataObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    AdvBaiduRenderFeedAdView *bdFeedAdView = [[AdvBaiduRenderFeedAdView alloc] initWithNativeAd:dataObject bridge:self.bridge adapter:self manager:nil viewController:nil];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:bdFeedAdView feedAdElement:element];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:[[dataObject getECPMLevel] integerValue]];
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(BaiduMobAdNativeAdObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.text;
    element.iconUrl = dataObject.iconImageURLString;
    if (dataObject.morepics.count) { // 三图
        element.imageUrlList = dataObject.morepics;
    } else if (dataObject.mainImageURLString.length) { // 单图
        element.imageUrlList = @[dataObject.mainImageURLString];
    }
    element.mediaWidth = dataObject.w.integerValue;
    element.mediaHeight = dataObject.h.integerValue;
    element.buttonText = dataObject.actButtonString;
    element.isVideoAd = (dataObject.materialType == VIDEO);
    element.videoDuration = dataObject.videoDuration.integerValue;
    element.isAdValid = !dataObject.isExpired;
    
    return element;
}

- (void)dealloc {
   
}

@end

