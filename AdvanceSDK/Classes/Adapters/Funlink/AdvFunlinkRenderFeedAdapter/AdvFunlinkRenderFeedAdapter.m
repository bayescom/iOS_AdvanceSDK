//
//  AdvFunlinkRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkRenderFeedAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvFunlinkRenderFeedAdViewCreator.h"
#import "AdvFunlinkRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvFunlinkRenderFeedAdapter () <FLinkNativeDelegate, FLinkNativeDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) FLinkNativeManager *flink_ad;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvFunlinkRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkNativeManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.adCount = 1;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    _flink_ad.showAdController = config[kAdvanceAdPresentControllerKey];
    [_flink_ad loadAdData];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_flink_ad sendWinNotificationWithPrice:result.secondPrice];
    } else {
        [_flink_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - FLinkNativeDelegate
- (void)nativeAdDidLoadDatas:(NSArray<__kindof FLinkFeedAdData *> *)datas {
    if (!datas.count) {
        NSError *error = [NSError errorWithDomain:@"FunlinkADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    FLinkFeedAdData *feedAdData = datas.firstObject;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvFunlinkRenderFeedAdDataSource alloc] initWithAdData:feedAdData];
    AdvFunlinkRenderFeedAdView<FLinkNativeAdRenderProtocol> *adView = [[AdvFunlinkRenderFeedAdView alloc] init];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.view = adView;
    self.feedAdWrapper.viewCreator = [[AdvFunlinkRenderFeedAdViewCreator alloc] initWithManager:self.flink_ad data:feedAdData adView:adView];
    
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:ecpm];
}

- (void)nativeAdDidFailed:(NSError *)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

#pragma mark - FLinkNativeDelegate
- (void)nativeAdDidVisible {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)nativeAdDidClicked {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)nativeAdDidCloseWithADView:(UIView *)nativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

- (void)dealloc {

}

@end
