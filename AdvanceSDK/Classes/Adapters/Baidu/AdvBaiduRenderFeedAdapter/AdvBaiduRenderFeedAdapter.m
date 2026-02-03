//
//  AdvBaiduRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "AdvBaiduRenderFeedAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvBaiduRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvBaiduRenderFeedAdapter () <BaiduMobAdNativeAdDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvBaiduRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
    _bd_ad = [[BaiduMobAdNative alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.adDelegate = self;
    _bd_ad.presentAdViewController = config[kAdvanceAdPresentControllerKey];
}

- (void)adapter_loadAd {
    [_bd_ad load];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

#pragma mark - BaiduMobAdNativeAdDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    BaiduMobAdNativeAdObject *dataObject = nativeAds.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    AdvBaiduRenderFeedAdView *bdFeedAdView = [[AdvBaiduRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adapterId:self.adapterId];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:bdFeedAdView feedAdElement:element];
    
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:[[dataObject getECPMLevel] integerValue]];
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:[[dataObject getECPMLevel] integerValue]];
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(BaiduMobAdNativeAdObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.text;
    element.iconUrl = dataObject.iconImageURLString;
    if (dataObject.morepics) { // 三图
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

