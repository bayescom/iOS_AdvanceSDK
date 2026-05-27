//
//  AdvCSJBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJBannerAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvCSJBannerAdapter () <BUNativeExpressBannerViewDelegate, AdvanceCommonBannerAdapter>

@property (nonatomic, weak) id<AdvanceCommonBannerAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressBannerView *csj_ad;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvCSJBannerAdapter

- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _csj_ad = [[BUNativeExpressBannerView alloc] initWithSlotID:placementId rootViewController:config[kAdvanceAdPresentControllerKey] adSize:adSize];
    _csj_ad.frame = rect;
    _csj_ad.delegate = self;
    [_csj_ad loadAdData];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (UIView *)adapter_bannerView {
    return self.bannerView;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_csj_ad win:@(result.secondPrice)];
    } else {
        [_csj_ad loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark: - BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    self.bannerView = bannerAdView;
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
    [self.csj_ad removeFromSuperview];
    self.csj_ad = nil;
    [self.bridge banner_didAdClosedWithAdapter:self];
}

- (void)dealloc {
   
}

@end
