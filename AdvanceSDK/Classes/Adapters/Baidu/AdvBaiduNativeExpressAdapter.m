//
//  AdvBaiduNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "AdvBaiduNativeExpressAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvBaiduNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, assign) CGSize adSize;
@property (nonatomic, strong) BaiduMobAdExpressNativeView *expressAdView;

@end

@implementation AdvBaiduNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    _bd_ad = [[BaiduMobAdNative alloc] init];
    _bd_ad.adDelegate = self;
    _bd_ad.adUnitTag = placementId;
    _bd_ad.publisherId = config[kAdvanceSupplierMediaIdKey];
    _bd_ad.baiduMobAdsWidth = @(self.adSize.width);
    _bd_ad.baiduMobAdsHeight = @(self.adSize.height);
    _bd_ad.presentAdViewController = config[kAdvanceAdPresentControllerKey];
    _bd_ad.isExpressNativeAds = YES;
    [_bd_ad load];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    self.expressAdView.baseViewController = viewController;
    self.expressAdView.interationDelegate = self;
    if (self.expressAdView.style_type == FeedType_PORTRAIT_VIDEO) {
        self.expressAdView.width = self.adSize.width * 0.8;
    }
    // 展示前检查是否过期，2h后广告将过期
    if (![self.expressAdView isExpired]) {
        [self.expressAdView render];
    } else {
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.expressAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.expressAdView biddingSuccessWithSecondInfo:@{@"ecpm": @(result.secondPrice)} completion:nil];
    } else {
        [self.expressAdView biddingFailWithWinInfo:@{@"ecpm": @(result.winPrice)} completion:nil];
    }
}


#pragma mark: - BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.expressAdView = (BaiduMobAdExpressNativeView *)nativeAds.firstObject;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:[[nativeAds.firstObject getECPMLevel] integerValue]];
}

- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    NSError *error = [NSError errorWithDomain:@"BaiduAdErrorDomain" code:[errCode integerValue] userInfo:@{NSLocalizedDescriptionKey: message ?: @""}];
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeAdExpressSuccessRender:(BaiduMobAdExpressNativeView *)express nativeAd:(BaiduMobAdNative *)nativeAd {
    express.frame = ({
        CGRect frame = express.frame;
        frame.origin.x = (self.adSize.width - express.frame.size.width) / 2;
        frame;
    });
    [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:express];
}

- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:nativeAdView];
}

- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
    [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:nativeAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:nativeAdView];
}

- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:adView];
}

- (void)dealloc {
    
}

@end
