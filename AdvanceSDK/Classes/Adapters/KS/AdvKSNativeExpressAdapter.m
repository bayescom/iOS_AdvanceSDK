//
//  AdvKSNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "AdvKSNativeExpressAdapter.h"
#import <KSAdSDK/KSAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvKSNativeExpressAdapter ()<KSFeedAdsManagerDelegate, KSFeedAdDelegate, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) KSFeedAdsManager *ks_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) KSFeedAd *feedAd;

@end

@implementation AdvKSNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _ks_ad = [[KSFeedAdsManager alloc] initWithPosId:placementId size:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _ks_ad.delegate = self;
    [_ks_ad loadAdDataWithCount:1];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    self.feedAd.delegate = self;
    if (self.feedAd.materialReady) { // 有效性判断
        [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:self.feedAd.feedView];
    } else {
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.feedAd.feedView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.feedAd setBidEcpm:result.winPrice highestLossEcpm:result.secondPrice];
    } else {
        KSAdExposureReportParam *param = [[KSAdExposureReportParam alloc] init];
        param.winEcpm = result.winPrice;
        [self.feedAd reportAdExposureFailed:KSAdExposureFailureBidFailed reportParam:param];
    }
}

#pragma mark: - KSFeedAdsManagerDelegate, KSFeedAdDelegate
- (void)feedAdsManagerSuccessToLoad:(KSFeedAdsManager *)adsManager nativeAds:(NSArray<KSFeedAd *> *_Nullable)feedAdDataArray {
    if (!feedAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"KSADErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.feedAd = feedAdDataArray.firstObject;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:feedAdDataArray.firstObject.ecpm];
}

- (void)feedAdsManager:(KSFeedAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

- (void)feedAdDidShow:(KSFeedAd *)feedAd {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:self.feedAd.feedView];
}

- (void)feedAdDidClick:(KSFeedAd *)feedAd {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:self.feedAd.feedView];
}

- (void)feedAdDislike:(KSFeedAd *)feedAd {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:self.feedAd.feedView];
}

- (void)dealloc {
    
}

@end
