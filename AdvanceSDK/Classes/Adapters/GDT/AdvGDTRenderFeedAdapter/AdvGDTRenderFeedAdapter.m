//
//  AdvGDTRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvGDTRenderFeedAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvGDTRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTRenderFeedAdapter () <GDTUnifiedNativeAdDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) GDTUnifiedNativeAd *gdt_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvGDTRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _gdt_ad = [[GDTUnifiedNativeAd alloc] initWithPlacementId:placementId];
    _gdt_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_gdt_ad loadAd];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}


#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
     
    GDTUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    AdvGDTRenderFeedAdView *gdtFeedAdView = [[AdvGDTRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adapterId:self.adapterId viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:gdtFeedAdView feedAdElement:element];
    
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:dataObject.eCPM];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.desc;
    element.iconUrl = dataObject.iconUrl;
    if (dataObject.isThreeImgsAd) { // 三图
        element.imageUrlList = dataObject.mediaUrlList;
    } else if (dataObject.imageUrl.length) { // 单图
        element.imageUrlList = @[dataObject.imageUrl];
    }
    element.mediaWidth = dataObject.imageWidth;
    element.mediaHeight = dataObject.imageHeight;
    element.buttonText = dataObject.buttonText;
    element.isVideoAd = [self isVideoAd:dataObject];
    element.videoDuration = dataObject.duration;
    element.appRating = dataObject.appRating;
    element.isAdValid = dataObject.isAdValid;
    return element;
}

- (BOOL)isVideoAd:(GDTUnifiedNativeAdDataObject *)dataObject {
    return [dataObject isVideoAd] || [dataObject isVastAd];
}

- (void)dealloc {
    
}

@end
