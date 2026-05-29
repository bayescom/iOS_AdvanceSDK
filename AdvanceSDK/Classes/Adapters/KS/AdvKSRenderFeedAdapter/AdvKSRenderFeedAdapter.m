//
//  AdvKSRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/10.
//

#import "AdvKSRenderFeedAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvKSRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"

@interface AdvKSRenderFeedAdapter () <KSNativeAdsManagerDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) KSNativeAdsManager *ks_ad;
@property (nonatomic, strong) KSNativeAd *nativeAd;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;

@end

@implementation AdvKSRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    _ks_ad = [[KSNativeAdsManager alloc] initWithPosId:placementId];
    _ks_ad.delegate = self;
    [_ks_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_nativeAd setBidEcpm:result.winPrice highestLossEcpm:result.secondPrice];
    } else {
        KSAdExposureReportParam *param = [[KSAdExposureReportParam alloc] init];
        param.winEcpm = result.winPrice;
        [_nativeAd reportAdExposureFailed:KSAdExposureFailureBidFailed reportParam:param];
    }
}


#pragma mark - KSNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(KSNativeAdsManager *)adsManager nativeAds:(NSArray<KSNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"KSADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    KSNativeAd *nativeAd = nativeAdDataArray.firstObject;
    self.nativeAd = nativeAd;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    AdvKSRenderFeedAdView *ksFeedAdView = [[AdvKSRenderFeedAdView alloc] initWithNativeAd:nativeAd bridge:self.bridge adapter:self manager:nil viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:ksFeedAdView feedAdElement:element];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:nativeAd.ecpm];
}

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
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
