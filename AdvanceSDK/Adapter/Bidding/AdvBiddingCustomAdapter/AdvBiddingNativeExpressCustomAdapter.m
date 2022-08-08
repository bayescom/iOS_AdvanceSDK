//
//  AdvBiddingNativeExpressCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/8.
//

#import "AdvBiddingNativeExpressCustomAdapter.h"

@implementation AdvBiddingNativeExpressCustomAdapter
/// 当前加载的广告的状态，native模板广告
- (ABUMediatedAdStatus)mediatedAdStatusWithExpressView:(UIView *)view {
    return ABUMediatedAdStatusUnknown;
}

/// 当前加载的广告的状态，native非模板广告
- (ABUMediatedAdStatus)mediatedAdStatusWithMediatedNativeAd:(ABUMediatedNativeAd *)ad {
    return ABUMediatedAdStatusUnknown;
}

- (void)loadNativeAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)size imageSize:(CGSize)imageSize parameter:(nonnull NSDictionary *)parameter {
    NSLog(@"----------->自定义开屏adapter开始加载啦啦<------------");
    [self.bridge nativeAd:self didClickWithMediatedNativeAd:nil];
    [self.bridge nativeAd:self willPresentFullScreenModalWithMediatedNativeAd:nil];
    [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:nil];
    [self.bridge nativeAd:self didCloseWithExpressView:nil closeReasons:@[]];

    [self.bridge nativeAd:self didLoadWithExpressViews:nil exts:nil];

}

- (void)registerContainerView:(nonnull __kindof UIView *)containerView andClickableViews:(nonnull NSArray<__kindof UIView *> *)views forNativeAd:(nonnull id)nativeAd {
}

- (void)renderForExpressAdView:(nonnull UIView *)expressAdView {
    // 如不adn广告不需要render，请尽量模拟回调renderSuccess
    [self.bridge nativeAd:self renderSuccessWithExpressView:expressAdView];
}

- (void)setRootViewController:(nonnull UIViewController *)viewController forExpressAdView:(nonnull UIView *)expressAdView {
}

- (void)setRootViewController:(nonnull UIViewController *)viewController forNativeAd:(nonnull id)nativeAd {
}

- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
}

@end
