//
//  AdvSigmobRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2025/3/19.
//

#import "AdvSigmobRenderFeedAdapter.h"
#import <WindSDK/WindSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvSigmobRenderFeedAdViewCreator.h"
#import "AdvSigmobRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvSigmobRenderFeedAdapter () <WindNativeAdsManagerDelegate, WindNativeAdViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) WindNativeAdsManager *sigmob_ad;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
@property (nonatomic, assign) BOOL hasFailed;

@end

@implementation AdvSigmobRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    WindAdRequest *request = [WindAdRequest request];
    request.placementId = placementId;
    _sigmob_ad = [[WindNativeAdsManager alloc] initWithRequest:request];
    _sigmob_ad.delegate = self;
    [_sigmob_ad loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    
}


#pragma mark: - WindNativeAdsManagerDelegate
/// 广告加载成功回调
- (void)nativeAdsManagerSuccessToLoad:(WindNativeAdsManager *)adsManager
                            nativeAds:(NSArray<WindNativeAd *> *)nativeAdDataArray {
    
    WindNativeAd *nativeAd = nativeAdDataArray.firstObject;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvSigmobRenderFeedAdDataSource alloc] initWithNativeAd:nativeAd];
    WindNativeAdView *adView = [[WindNativeAdView alloc] init];
    adView.delegate = self;
    adView.viewController = self.rootViewController;
    
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.view = adView;
    self.feedAdWrapper.viewCreator = [[AdvSigmobRenderFeedAdViewCreator alloc] initWithNativeAd:nativeAd adView:adView];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:adsManager.getEcpm.integerValue];
}

/// 广告加载出错回调
- (void)nativeAdsManager:(WindNativeAdsManager *)adsManager
        didFailWithError:(NSError *)error {
    if (!_hasFailed) { /// 某些错误码时，会重复进入此回调导致接口频繁上报线程崩溃
        _hasFailed = YES;
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
    }
}

#pragma mark - WindNativeAdViewDelegate
/// 广告曝光回调
- (void)nativeAdViewWillExpose:(WindNativeAdView *)nativeAdView {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

/// 广告点击回调
- (void)nativeAdViewDidClick:(WindNativeAdView *)nativeAdView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

/// 视频播放结束回调
- (void)nativeAdView:(WindNativeAdView *)nativeAdView playerStatusChanged:(WindMediaPlayerStatus)status userInfo:(NSDictionary *)userInfo {
    if (status == WindMediaPlayerStatusStoped) {
        [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
    }
}

- (void)dealloc {

}

@end
