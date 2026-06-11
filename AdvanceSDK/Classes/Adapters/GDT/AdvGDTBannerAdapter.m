//
//  AdvGDTBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvGDTBannerAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvGDTBannerAdapter () <GDTUnifiedBannerViewDelegate, AdvanceCommonBannerAdapter>

@property (nonatomic, weak) id<AdvanceCommonBannerAdapterBridge> bridge;
@property (nonatomic, strong) GDTUnifiedBannerView *gdt_ad;

@end

@implementation AdvGDTBannerAdapter

- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _gdt_ad = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:placementId viewController:config[kAdvanceAdPresentControllerKey]];
    _gdt_ad.animated = NO;
    _gdt_ad.autoSwitchInterval = 0; // 暂不支持刷新
    _gdt_ad.delegate = self;
    [_gdt_ad loadAdAndShow];
}

- (BOOL)adapter_isAdValid {
    return _gdt_ad.isAdValid;
}

- (UIView *)adapter_bannerView {
    return self.gdt_ad;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_gdt_ad sendWinNotificationWithInfo:@{GDT_M_W_H_LOSS_PRICE: @(result.secondPrice), GDT_M_W_E_COST_PRICE: @(result.winPrice)}];
    } else {
        [_gdt_ad sendLossNotificationWithInfo:@{GDT_M_L_WIN_PRICE: @(result.winPrice)}];
    }
}

#pragma mark: - GDTUnifiedBannerViewDelegate
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.bridge banner_didLoadAdWithAdapter:self price:unifiedBannerView.eCPM];
}

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
    [self.bridge banner_failedToLoadAdWithAdapter:self error:error];
}

- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.bridge banner_didAdExposuredWithAdapter:self];
}

- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.bridge banner_didAdClickedWithAdapter:self];
}

- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
    [_gdt_ad removeFromSuperview];
    _gdt_ad = nil;
    [self.bridge banner_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
