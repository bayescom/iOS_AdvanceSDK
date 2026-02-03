//
//  AdvMercuryRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "AdvMercuryRenderFeedAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvMercuryRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvMercuryRenderFeedAdapter () <MercuryUnifiedNativeAdDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) MercuryUnifiedNativeAd *mercury_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvMercuryRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _mercury_ad = [[MercuryUnifiedNativeAd alloc] initAdWithAdspotId:placementId delegate:self];
}

- (void)adapter_loadAd {
    [_mercury_ad loadAd];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

#pragma mark - MercuryUnifiedNativeAdDelegate
- (void)mercury_unifiedNativeAdLoaded:(NSArray<MercuryUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    MercuryUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    AdvMercuryRenderFeedAdView *mercuryFeedAdView = [[AdvMercuryRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adapterId:self.adapterId viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:mercuryFeedAdView feedAdElement:element];
    
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:dataObject.price];
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:dataObject.price];
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
