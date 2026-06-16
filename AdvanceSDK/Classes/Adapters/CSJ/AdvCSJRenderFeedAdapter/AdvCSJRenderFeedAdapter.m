//
//  AdvCSJRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "AdvCSJRenderFeedAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvCSJRenderFeedAdViewCreator.h"
#import "AdvCSJRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvCSJRenderFeedAdapter () <BUNativeAdsManagerDelegate, BUNativeAdDelegate, BUCustomEventProtocol, BUVideoAdViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeAdsManager *csj_ad;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvCSJRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = placementId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionTop;
    slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
    _csj_ad = [[BUNativeAdsManager alloc] initWithSlot:slot];
    _csj_ad.delegate = self;
    [_csj_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_nativeAd win:@(result.secondPrice)];
    } else {
        [_nativeAd loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"BUAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    self.nativeAd = nativeAd;
    self.nativeAd.delegate = self;
    self.nativeAd.rootViewController = self.rootViewController;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvCSJRenderFeedAdDataSource alloc] initWithNativeAdData:nativeAd.data];
    BUNativeAdRelatedView *adView = [[BUNativeAdRelatedView alloc] init]; // 非UIView类型
    if (dataSource.isVideoAd) {
        adView.mediaAdView.delegate = self;
    }
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.viewCreator = [[AdvCSJRenderFeedAdViewCreator alloc] initWithNativeAd:self.nativeAd adView:adView];
    
    NSDictionary *ext = nativeAd.data.mediaExt;
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

#pragma mark - BUNativeAdDelegate
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd {
    
}
- (void)nativeAdDidLoad:(BUNativeAd *)nativeAd view:(UIView *)view {
    
}

- (void)nativeAd:(BUNativeAd *)nativeAd didFailWithError:(NSError *_Nullable)error {
    
}

- (void)nativeAdDidBecomeVisible:(BUNativeAd *)nativeAd {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)nativeAdDidCloseOtherController:(BUNativeAd *)nativeAd interactionType:(BUInteractionType)interactionType {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

- (void)nativeAdDidClick:(BUNativeAd *)nativeAd withView:(UIView *_Nullable)view {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)nativeAd:(BUNativeAd *)nativeAd dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    
}

#pragma mark - BUVideoAdViewDelegate
- (void)videoAdView:(BUMediaAdView *)adView stateDidChanged:(BUPlayerPlayState)playerState {
    
}

- (void)videoAdView:(BUMediaAdView *)adView didLoadFailWithError:(NSError *_Nullable)error {
    
}

- (void)playerDidPlayFinish:(BUMediaAdView *)adView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)videoAdViewDidClick:(BUMediaAdView *)adView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)videoAdViewFinishViewDidClick:(BUMediaAdView *)adView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)videoAdViewDidCloseOtherController:(BUMediaAdView *)adView interactionType:(BUInteractionType)interactionType {
    
}

- (void)videoAdView:(BUMediaAdView *)adView
 rewardDidCountDown:(NSInteger)countDown {
    
}

- (void)dealloc {
    
}

@end
