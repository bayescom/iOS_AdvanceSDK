//
//  AdvBiddingNativeExpressCustomAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/25.
//

#import "AdvBiddingNativeExpressCustomAdapter.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import <AdvanceSDK/AdvanceNativeExpress.h>
#import <AdvanceSDK/AdvanceNativeExpressAd.h>
#import "GroMoreBiddingManager.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvBiddingNativeExpressCustomAdapter () <ABUCustomNativeAdapter, AdvanceNativeExpressDelegate>

@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, assign) NSInteger biddingType;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingNativeExpressCustomAdapter

- (ABUMediatedAdStatus)mediatedAdStatusWithExpressView:(UIView *)view {
    return ABUMediatedAdStatusNormal;
}

// Client Bidding的结果回调
- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    
}

- (void)loadNativeAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)size imageSize:(CGSize)imageSize parameter:(nonnull NSDictionary *)parameter {
    
    _biddingType = [[parameter objectForKey:ABUAdLoadingParamBiddingType] integerValue];
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:slotID customExt:nil viewController:self.bridge.viewControllerForPresentingModalView adSize:size];
    
    _advanceFeed.delegate = self;
    _advanceFeed.muted = [parameter[ABUAdLoadingParamNAIsMute] boolValue];
    _advanceFeed.isGroMoreADN = YES;
    /// 并发加载各个渠道SDK
    [_advanceFeed catchBidTargetWhenGroMoreBiddingWithPolicyModel:GroMoreBiddingManager.policyModel];
}

- (void)renderForExpressAdView:(nonnull UIView *)expressAdView {
    SEL selector = NSSelectorFromString(@"renderNativeAdView");
    if ([self.advanceFeed.targetAdapter respondsToSelector:selector]) {
        ((void (*)(id, SEL))objc_msgSend)(self.advanceFeed.targetAdapter, selector);
    }
}

- (void)setRootViewController:(nonnull UIViewController *)viewController forExpressAdView:(nonnull UIView *)expressAdView {
    
}

- (void)registerContainerView:(nonnull __kindof UIView *)containerView andClickableViews:(nonnull NSArray<__kindof UIView *> *)views forNativeAd:(nonnull id)nativeAd {}

- (void)setRootViewController:(nonnull UIViewController *)viewController forNativeAd:(nonnull id)nativeAd {}


#pragma mark: - AdvanceNativeExpressDelegate

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description{
    [self.bridge nativeAd:self didLoadFailWithError:error];
}

- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
}

/// 信息流广告数据拉取成功
- (void)didFinishLoadingNativeExpressAds:(NSArray<AdvanceNativeExpressAd *> *)nativeAds spotId:(NSString *)spotId {
    
    AdvanceNativeExpressAd *nativeAd = nativeAds.firstObject;
    NSMutableDictionary *extra = [@{} mutableCopy];
    if (self.biddingType == 1) { // client
        NSString *cpm = [NSString stringWithFormat:@"%ld", (long)self.price];
        [extra setObject:cpm forKey:ABUMediaAdLoadingExtECPM];
    }
    
    [self.bridge nativeAd:self didLoadWithExpressViews:@[nativeAd.expressView] exts:@[extra]];
}

/// 信息流广告渲染成功
- (void)nativeExpressAdViewRenderSuccess:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge nativeAd:self renderSuccessWithExpressView:nativeAd.expressView];
}

/// 信息流广告渲染失败
- (void)nativeExpressAdViewRenderFail:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge nativeAd:self renderFailWithExpressView:nativeAd.expressView andError:[NSError errorWithDomain:@"ABUNative.com" code:1 userInfo:@{@"msg":@"信息流广告渲染失败"}]];
}

/// 信息流广告曝光
-(void)didShowNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge nativeAd:self didVisibleWithMediatedNativeAd:nativeAd.expressView];
}

/// 信息流广告点击
-(void)didClickNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge nativeAd:self didClickWithMediatedNativeAd:nativeAd.expressView];
}

/// 信息流广告被关闭
-(void)didCloseNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd spotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceFeed = nil;
    [self.bridge nativeAd:self didCloseWithExpressView:nativeAd.expressView closeReasons:nil];
}

@end
