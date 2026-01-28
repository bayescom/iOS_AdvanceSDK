//
//  AdvCSJBannerAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJBannerAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceBannerCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvCSJBannerAdapter () <BUNativeExpressBannerViewDelegate, AdvanceBannerCommonAdapter>
@property (nonatomic, strong) BUNativeExpressBannerView *csj_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvCSJBannerAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    CGSize adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    CGRect rect = CGRectMake(0, 0, adSize.width, adSize.height);
    _csj_ad = [[BUNativeExpressBannerView alloc] initWithSlotID:placementId rootViewController:config[kAdvanceAdPresentControllerKey] adSize:adSize];
    _csj_ad.frame = rect;
    _csj_ad.delegate = self;
}

- (void)adapter_loadAd {
    [_csj_ad loadAdData];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (id)adapter_bannerView {
    return self.bannerView;
}


#pragma mark: - BUNativeExpressBannerViewDelegate
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    self.bannerView = bannerAdView;
    NSDictionary *ext = bannerAdView.mediaExt;
    [self.delegate bannerAdapter_didLoadAdWithAdapterId:self.adapterId price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self.delegate bannerAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate bannerAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)nativeExpressBannerAdViewRenderFail:(BUNativeExpressBannerView *)bannerAdView error:(NSError *)error {
    [self.delegate bannerAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.delegate bannerAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    [self.csj_ad removeFromSuperview];
    self.csj_ad = nil;
    [self.delegate bannerAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
   
}

@end
