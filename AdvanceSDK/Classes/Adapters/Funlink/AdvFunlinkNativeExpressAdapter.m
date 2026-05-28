//
//  AdvFunlinkNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2020/4/14.
//

#import "AdvFunlinkNativeExpressAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvFunlinkNativeExpressAdapter () <FLinkNativeDelegate, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) FLinkNativeManager *flink_ad;
@property (nonatomic, strong) UIView *expressAdView;

@end

@implementation AdvFunlinkNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkNativeManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.adCount = 1;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    [_flink_ad loadAdData];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    _flink_ad.showAdController = viewController;
    // 如果adn广告不需要render，请尽量模拟回调renderSuccess
    if (self.flink_ad.getCurrentBaseEcpmInfo.isAdValid) { // 有效性判断
        [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:self.expressAdView];
    } else {
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.expressAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
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
        NSError *error = [NSError errorWithDomain:@"FunlinkAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.expressAdView = datas.firstObject.adView;
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:ecpm];
}

- (void)nativeAdDidFailed:(NSError *)error {
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeAdDidVisible {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:self.expressAdView];
}

- (void)nativeAdDidClicked {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:self.expressAdView];
}

- (void)nativeAdDidCloseWithADView:(UIView *)nativeAdView {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:self.expressAdView];
}

- (void)dealloc {
    
}

@end
