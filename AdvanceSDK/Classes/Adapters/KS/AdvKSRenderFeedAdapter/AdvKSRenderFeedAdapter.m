//
//  AdvKSRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "AdvKSRenderFeedAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvKSRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvKSRenderFeedAdapter () <KSNativeAdsManagerDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) KSNativeAdsManager *ks_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation AdvKSRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _ks_ad = [[KSNativeAdsManager alloc] initWithPosId:placementId];
    _ks_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_ks_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}


#pragma mark - KSNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(KSNativeAdsManager *)adsManager nativeAds:(NSArray<KSNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"KSADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    KSNativeAd *nativeAd = nativeAdDataArray.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    AdvKSRenderFeedAdView *ksFeedAdView = [[AdvKSRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adapterId:self.adapterId viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:ksFeedAdView feedAdElement:element];
    
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:nativeAd.ecpm];
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:nativeAd.ecpm];
}

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(KSNativeAd *)nativeAd {
    KSMaterialMeta *data = nativeAd.data;
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = data.appName.length ? data.appName : data.productName;
    element.desc = data.adDescription;
    element.iconUrl = data.appIconImage.imageURL;
    NSMutableArray *urlList = [NSMutableArray array];
    for (KSAdImage *image in data.imageArray) {
        [urlList addObject:image.imageURL];
    }
    element.imageUrlList = [urlList copy];
    element.mediaWidth = data.imageArray.firstObject.width;
    element.mediaHeight = data.imageArray.firstObject.height;
    element.buttonText = data.actionDescription;
    element.isVideoAd = (data.materialType == KSAdMaterialTypeVideo);
    if (element.isVideoAd) {
        element.mediaWidth = data.videoCoverImage.width;
        element.mediaHeight = data.videoCoverImage.height;
    }
    element.videoDuration = data.videoDuration;
    element.appRating = data.appScore;
    element.isAdValid = YES;
    return element;
}

- (void)dealloc {

}

@end
