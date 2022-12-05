//
//  AdvBiddingNativeExpressCustomAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/8.
//

#import "AdvBiddingNativeExpressCustomAdapter.h"
//#import <AdvanceSDK/AdvanceNativeExpress.h>
//#import <AdvanceSDK/AdvanceNativeExpressView.h>
#import "AdvBiddingNativeScapegoat.h"
#import "AdvBiddingCongfig.h"
#import "AdvSupplierModel.h"
@interface AdvBiddingNativeExpressCustomAdapter ()
@property(strong,nonatomic) AdvanceNativeExpress *advanceFeed;
@property (nonatomic, strong) AdvBiddingNativeScapegoat *scapegoat;

@end

@implementation AdvBiddingNativeExpressCustomAdapter

- (AdvBiddingNativeScapegoat *)scapegoat{
    if (_scapegoat == nil) {
        _scapegoat = [[AdvBiddingNativeScapegoat alloc]init];
        _scapegoat.a = self;
    }
    return _scapegoat;
}

/// 当前加载的广告的状态，native模板广告
- (ABUMediatedAdStatus)mediatedAdStatusWithExpressView:(UIView *)view {
    return ABUMediatedAdStatusUnknown;
}

/// 当前加载的广告的状态，native非模板广告
- (ABUMediatedAdStatus)mediatedAdStatusWithMediatedNativeAd:(ABUMediatedNativeAd *)ad {
    return ABUMediatedAdStatusUnknown;
}

- (void)loadNativeAdWithSlotID:(nonnull NSString *)slotID andSize:(CGSize)size imageSize:(CGSize)imageSize parameter:(nonnull NSDictionary *)parameter {
//    NSLog(@"----------->自定义开屏adapter开始加载啦啦<------------");
    
    AdvSupplierModel *model = [[AdvBiddingCongfig defaultManager] returnSupplierByAdspotId:slotID];
    
    _advanceFeed = [[AdvanceNativeExpress alloc] initWithAdspotId:slotID customExt:nil viewController:self.bridge.viewControllerForPresentingModalView adSize:size];

    _advanceFeed.delegate = self.scapegoat;
    [_advanceFeed loadAdWithSupplierModel:model];

}

- (void)registerContainerView:(nonnull __kindof UIView *)containerView andClickableViews:(nonnull NSArray<__kindof UIView *> *)views forNativeAd:(nonnull id)nativeAd {
    
}

- (void)renderForExpressAdView:(nonnull UIView *)expressAdView {
    // 如不adn广告不需要render，请尽量模拟回调renderSuccess
//    NSLog(@"renderForExpressAdView   %@", expressAdView);
//    [self.bridge nativeAd:self renderSuccessWithExpressView:expressAdView];
    if ([expressAdView isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
        [expressAdView isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")] ||
        [expressAdView isKindOfClass:NSClassFromString(@"CSJNativeExpressAdView")]) {
        [expressAdView performSelector:@selector(render)];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
        [expressAdView performSelector:@selector(render)];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
        [expressAdView performSelector:@selector(render)];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
        [expressAdView performSelector:@selector(render)];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"BaiduMobAdSmartFeedView")]) {// 百度
        [expressAdView performSelector:@selector(render)];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"ABUNativeAdView")]) {// bidding
        [expressAdView performSelector:@selector(render)];
    } else { // 快手 或 tanx
        
    }

}

- (void)setRootViewController:(nonnull UIViewController *)viewController forExpressAdView:(nonnull UIView *)expressAdView {
//    NSLog(@"setRootViewController   %@ %@", expressAdView, viewController);
    if ([expressAdView isKindOfClass:NSClassFromString(@"BUNativeExpressFeedVideoAdView")] ||
        [expressAdView isKindOfClass:NSClassFromString(@"BUNativeExpressAdView")] ||
        [expressAdView isKindOfClass:NSClassFromString(@"CSJNativeExpressAdView")]) {

        [expressAdView performSelector:@selector(setRootViewController:) withObject:viewController];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
        [expressAdView performSelector:@selector(setController:) withObject:viewController];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"GDTNativeExpressAdView")]) {// 广点通旧版信息流
        [expressAdView performSelector:@selector(setController:) withObject:viewController];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"GDTNativeExpressProAdView")]) {// 广点通新版信息流
        [expressAdView performSelector:@selector(setController:) withObject:viewController];
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"BaiduMobAdSmartFeedView")]) {// 百度
    } else if ([expressAdView isKindOfClass:NSClassFromString(@"ABUNativeAdView")]) {// bidding
    } else { // 快手 或 tanx
        
    }

}

- (void)setRootViewController:(nonnull UIViewController *)viewController forNativeAd:(nonnull id)nativeAd {
    
}

- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    // 在此处理Client Bidding的结果回调
}

- (void)dealloc {
    
}


@end
