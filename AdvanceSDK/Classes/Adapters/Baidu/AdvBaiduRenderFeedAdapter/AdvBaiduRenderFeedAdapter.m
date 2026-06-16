//
//  AdvBaiduRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/15.
//

#import "AdvBaiduRenderFeedAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvBaiduRenderFeedAdViewCreator.h"
#import "AdvBaiduRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvBaiduRenderFeedAdapter () <BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate, BaiduMobAdNativeVideoViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, strong) BaiduMobAdNativeAdObject *dataObject;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;

@end

@implementation AdvBaiduRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bd_ad = [[BaiduMobAdNative alloc] init];
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.adDelegate = self;
    _bd_ad.presentAdViewController = config[kAdvanceAdPresentControllerKey];
    [_bd_ad load];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.dataObject biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    } else {
        [self.dataObject biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:^(BOOL success, NSString * _Nonnull errorInfo) {}];
    }
}


#pragma mark - BaiduMobAdNativeAdDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    BaiduMobAdNativeAdObject *dataObject = nativeAds.firstObject;
    self.dataObject = dataObject;
    self.dataObject.interationDelegate = self;
    id<AdvRenderFeedAdDataSource> dataSource = [[AdvBaiduRenderFeedAdDataSource alloc] initWithDataObject:dataObject];
    BaiduMobAdNativeVideoView *bdVideoView = nil;
    if (dataSource.isVideoAd) {
        bdVideoView = [[BaiduMobAdNativeVideoView alloc] initWithFrame:CGRectZero andObject:dataObject];
        bdVideoView.videoDelegate = self;
    }
    BaiduMobAdNativeAdView *adView = [[BaiduMobAdNativeAdView alloc] init];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
    self.feedAdWrapper.dataSource = dataSource;
    self.feedAdWrapper.view = adView;
    self.feedAdWrapper.viewCreator = [[AdvBaiduRenderFeedAdViewCreator alloc] initWithDataObject:dataObject adView:adView videoView:bdVideoView];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:[[dataObject getECPMLevel] integerValue]];
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

#pragma mark - BaiduMobAdNativeInterationDelegate

/**
 *  广告曝光成功
 */
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

/**
 *  广告曝光失败
 */
- (void)nativeAdExposureFail:(UIView *)nativeAdView
          nativeAdDataObject:(BaiduMobAdNativeAdObject *)object
                  failReason:(int)reason {
    
}

/**
 *  广告点击
 */
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

/**
 *  广告详情页关闭
 */
- (void)didDismissLandingPage:(UIView *)nativeAdView {
    [self.bridge renderFeed_didAdClosedDetailPageWithAdapter:self];
}

#pragma mark - BaiduMobAdNativeVideoViewDelegate
/**
 视频播放完成
 */
- (void)nativeVideoAdDidComplete:(BaiduMobAdNativeVideoView *)videoView {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
   
}

@end

