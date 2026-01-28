//
//  AdvCSJRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvCSJRenderFeedAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvCSJRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvCSJRenderFeedAdapter () <BUNativeAdsManagerDelegate, AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) BUNativeAdsManager *csj_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvCSJRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = placementId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionTop;
    slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
    _csj_ad = [[BUNativeAdsManager alloc] initWithSlot:slot];
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_csj_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"BUAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
        return;
    }
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    NSDictionary *ext = nativeAd.data.mediaExt;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    AdvCSJRenderFeedAdView *csjFeedAdView = [[AdvCSJRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adapterId:self.adapterId viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:csjFeedAdView feedAdElement:element];
    
    [self.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(BUNativeAd *)nativeAd {
    BUMaterialMeta *data = nativeAd.data;
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = data.AdTitle;
    element.desc = data.AdDescription;
    element.iconUrl = data.icon.imageURL;
    NSMutableArray *urlList = [NSMutableArray array];
    for (BUImage * image in data.imageAry) {
        [urlList addObject:image.imageURL];
    }
    element.imageUrlList = [urlList copy];
    element.mediaWidth = data.imageAry.firstObject.width;
    element.mediaHeight = data.imageAry.firstObject.height;
    element.buttonText = data.buttonText;
    element.isVideoAd = [self isVideoAd:nativeAd];
    if (element.isVideoAd) {
        element.mediaWidth = data.videoResolutionWidth;
        element.mediaHeight = data.videoResolutionHeight;
    }
    element.videoDuration = data.videoDuration;
    element.appRating = data.score;
    element.isAdValid = YES;
    
    return element;
}

- (BOOL)isVideoAd:(BUNativeAd *)nativeAd {
    switch (nativeAd.data.imageMode) {
        case BUFeedVideoAdModeImage:
        case BUFeedVideoAdModePortrait:
        case BUFeedADModeSquareVideo:
        //Live Stream Ad. v5200 add
        case 166:
            return YES;
            
        default:
            return NO;
    }
}

- (void)dealloc {
    
}

@end
