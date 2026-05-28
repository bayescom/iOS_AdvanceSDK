//
//  AdvMercuryNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvMercuryNativeExpressAdapter.h"
#import <MercurySDK/MercurySDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvMercuryNativeExpressAdapter () <MercuryNativeExpressAdDelegete, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) MercuryNativeExpressAd *mercury_ad;
@property (nonatomic, strong) MercuryNativeExpressAdView *expressAdView;

@end

@implementation AdvMercuryNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _mercury_ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:placementId];
    _mercury_ad.renderSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    _mercury_ad.delegate = self;
    [_mercury_ad loadAdWithCount:1];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    self.expressAdView.controller = viewController;
    if (self.expressAdView.isAdValid) { // 有效性判断
        [self.expressAdView render];
    } else {
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.expressAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeLoss) {
        [self.expressAdView sendLossNotificationWithPrice:result.winPrice];
    }
}


#pragma mark: - MercuryNativeExpressAdDelegete
/// 拉取原生模板广告成功
- (void)mercury_nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(NSArray<MercuryNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"MercuryAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.expressAdView = views.firstObject;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:views.firstObject.price];
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoad:(MercuryNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:nativeExpressAdView];
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:nativeExpressAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:nativeExpressAdView];
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:nativeExpressAdView];
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:nativeExpressAdView];
}

- (void)dealloc {
    
}

@end
