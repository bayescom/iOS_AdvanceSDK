//
//  AdvNoahNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import "AdvNoahNativeExpressAdapter.h"
#import <NoahSDK/NoahSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvNoahNativeExpressAdapter () <NoahSdkNativeListener, NANativeViewDataSource, NANativeViewDelegate, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) NativeAd *noah_ad;
@property (nonatomic, strong) UIView *nativeAdView;

@end

@implementation AdvNoahNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    RequestInfo *requestInfo = [RequestInfo new];
    requestInfo.slotKey = placementId;
    [NativeAd loadAdWithReqInfo:requestInfo adDelegate:self];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    UIView<NANativeViewProtocol> *adView = [self.noah_ad nativeAdViewWithDataSource:self delegate:self];
    adView.themeMode = NAThemeLight;
    self.nativeAdView = adView;
    self.noah_ad.adViewController = viewController;
    // 如果adn广告不需要render，请尽量模拟回调renderSuccess
    if (self.noah_ad.isValid) { // 有效性判断
        [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:self.nativeAdView];
    } else {
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.nativeAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
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
    self.noah_ad = nativeAds.firstObject;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:self.noah_ad.price];
}

- (void)onNativeAdLoadFail:(RequestInfo *)reqInfo error:(nullable AdError *)error {
    NSError *err = [NSError errorWithDomain:@"NoahAdErrorDomain" code:[error getErrorCode] userInfo:@{NSLocalizedDescriptionKey: [error getErrorMessage] ?: @""}];
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:err];
}

- (void)onNativeAdShown:(NativeAd *)ad {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:self.nativeAdView];
}

- (void)onNativeAdClick:(NativeAd *)ad {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:self.nativeAdView];
}

#pragma mark: - NANativeViewDelegate
/// 关闭按钮点击
- (void)nativeAdViewDidClickCloseButton:(id<NANativeViewProtocol>)adView {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:self.nativeAdView];
}

- (void)dealloc {
    
}

@end
