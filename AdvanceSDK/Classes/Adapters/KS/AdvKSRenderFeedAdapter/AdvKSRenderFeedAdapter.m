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
#import "AdvKSRenderFeedAdViewCreator.h"
#import "AdvKSRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvKSRenderFeedAdapter () <KSNativeAdsManagerDelegate, KSNativeAdDelegate, AdvanceCommonRenderFeedAdapter>

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
    self.nativeAd.delegate = self;
    self.nativeAd.rootViewController = self.rootViewController;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvKSRenderFeedAdDataSource alloc] initWithNativeAdData:nativeAd.data];
    KSNativeAdRelatedView *adView = [[KSNativeAdRelatedView alloc] init]; // 非UIView类型
    
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.viewCreator = [[AdvKSRenderFeedAdViewCreator alloc] initWithNativeAd:self.nativeAd adView:adView];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:nativeAd.ecpm];
}

- (void)nativeAdsManager:(KSNativeAdsManager *)adsManager didFailWithError:(NSError *_Nullable)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

#pragma mark - KSNativeAdDelegate

- (void)nativeAdDidLoad:(KSNativeAd *)nativeAd {
    
}

- (void)nativeAd:(KSNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeAdDidBecomeVisible:(KSNativeAd *)nativeAd {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)nativeAdDidCloseOtherController:(KSNativeAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

- (void)nativeAdDidClick:(KSNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)nativeAdVideoPlayFinished:(KSNativeAd *)nativeAd {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)nativeAdVideoPlayError:(KSNativeAd *)nativeAd {
    
}

- (void)dealloc {

}

@end
