//
//  AdvNoahRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahRenderFeedAdapter.h"
#import <NoahSDK/NoahSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvNoahRenderFeedAdViewCreator.h"
#import "AdvNoahRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvNoahRenderFeedAdapter () <NoahSdkNativeListener, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) NativeAd *noah_ad;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvNoahRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    RequestInfo *requestInfo = [RequestInfo new];
    requestInfo.slotKey = placementId;
    [NativeAd loadAdWithReqInfo:requestInfo adDelegate:self];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_noah_ad sendWinNotification:result.secondPrice];
    } else {
        [_noah_ad sendLossNotification:result.winPrice reason:0];
    }
}

#pragma mark: - NoahNativeAdListener
- (void)onNativeAdDidLoad:(NSArray<NativeAd *> *)nativeAds {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"NoahADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.noah_ad = nativeAds.firstObject;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvNoahRenderFeedAdDataSource alloc] initWithAdAssets:self.noah_ad.adAssets];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.viewCreator = [[AdvNoahRenderFeedAdViewCreator alloc] initWithNativeAd:self.noah_ad];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:self.noah_ad.price];
}

- (void)onNativeAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error {
    NSError *err = [NSError errorWithDomain:@"NoahAdErrorDomain" code:[error getErrorCode] userInfo:@{NSLocalizedDescriptionKey: [error getErrorMessage] ?: @""}];
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:err];
}

- (void)onNativeAdShown:(NativeAd *)ad {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)onNativeAdClick:(NativeAd *)ad {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)dealloc {

}

@end
