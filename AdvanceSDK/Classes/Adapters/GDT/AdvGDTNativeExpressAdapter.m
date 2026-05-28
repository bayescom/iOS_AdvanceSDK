//
//  AdvGDTNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTNativeExpressAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvGDTNativeExpressAdapter () <GDTNativeExpressAdDelegete, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, strong) GDTNativeExpressAdView *expressAdView;

@end

@implementation AdvGDTNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _gdt_ad = [[GDTNativeExpressAd alloc] initWithPlacementId:placementId
                                                       adSize:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _gdt_ad.videoMuted = [config[kAdvanceAdVideoMutedKey] boolValue];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd:1];
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
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.expressAdView sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [self.expressAdView sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}


#pragma mark: - GDTNativeExpressAdDelegete
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"GDTAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.expressAdView = views.firstObject;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:views.firstObject.eCPM];
}

- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:nativeExpressAdView error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:nativeExpressAdView];
}

- (void)dealloc {
    
}

@end
