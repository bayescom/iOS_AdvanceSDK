//
//  AdvXXCustomBannerAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/8.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomBannerAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvanceCommonAdapter.h>
#import <AdvanceSDK/AdvAdConfigHeader.h>

@interface AdvXXCustomBannerAdapter () <BUNativeExpressBannerViewDelegate, AdvanceCommonBannerAdapter>

@property (nonatomic, weak) id<AdvanceCommonBannerAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressBannerView *bannerAdView;

@end

@implementation AdvXXCustomBannerAdapter

- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _bannerAdView = [[BUNativeExpressBannerView alloc] initWithSlotID:placementId rootViewController:config[kAdvanceAdPresentControllerKey] adSize:adSize];
    _bannerAdView.frame = rect;
    _bannerAdView.delegate = self;
    [_bannerAdView loadAdData];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (UIView *)adapter_bannerView {
    return self.bannerAdView;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_bannerAdView win:@(result.secondPrice)];
    } else {
        [_bannerAdView loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark: - BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    NSDictionary *ext = bannerAdView.mediaExt;
    [self.bridge banner_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self.bridge banner_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.bridge banner_didAdExposuredWithAdapter:self];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    [self.bridge banner_failedToShowAdWithAdapter:self error:error];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.bridge banner_didAdClickedWithAdapter:self];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [self.bannerAdView removeFromSuperview];
    self.bannerAdView = nil;
    [self.bridge banner_didAdClosedWithAdapter:self];
}

- (void)dealloc {
   
}

@end
