//
//  AdvBiddingSplashCustomAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/18.
//

#import "AdvBiddingSplashCustomAdapter.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import <AdvanceSDK/AdvanceSplash.h>
#import "GroMoreBiddingManager.h"

@interface AdvBiddingSplashCustomAdapter () <ABUCustomSplashAdapter, AdvanceSplashDelegate>

@property (nonatomic, strong) AdvanceSplash *advanceSplash;
@property (nonatomic, assign) NSInteger biddingType;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingSplashCustomAdapter

#pragma mark: - ABUCustomSplashAdapter

- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

- (void)dismissSplashAd {
    self.advanceSplash = nil;
}

// Client Bidding的结果回调
- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    
}

// 启动新的Advance广告位，命中BidTarget，再回传给gromore竞价
- (void)loadSplashAdWithSlotID:(nonnull NSString *)slotID andParameter:(nonnull NSDictionary *)parameter {
    
    UIImageView *logoView = (UIImageView *)[parameter objectForKey:ABUAdLoadingParamSPCustomBottomView];
    _biddingType = [[parameter objectForKey:ABUAdLoadingParamBiddingType] integerValue];
    
    _advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:slotID
                                                   customExt:nil
                                              viewController:self.bridge.viewControllerForPresentingModalView];
    _advanceSplash.delegate = self;
    if (logoView) {
        _advanceSplash.logoImage = logoView.image;
        _advanceSplash.showLogoRequire = YES;
    }
    /// 并发加载各个渠道SDK
    [_advanceSplash catchBidTargetWhenGroMoreBiddingWithPolicyModel:GroMoreBiddingManager.policyModel];

}

- (void)showSplashAdInWindow:(nonnull UIWindow *)window parameter:(nonnull NSDictionary *)parameter {

    [_advanceSplash showInWindow:window];
}

#pragma mark: - AdvanceSplashDelegate

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    [self.bridge splashAd:self didLoadFailWithError:error ext:description];
}

/// 竞价成功
- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
}

/// 开屏广告数据拉取成功
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId {
    NSMutableDictionary *extra = [@{} mutableCopy];
    if (self.biddingType == 1) { // client
        NSString *cpm = [NSString stringWithFormat:@"%ld", (long)self.price];
        [extra setObject:cpm forKey:ABUMediaAdLoadingExtECPM];
    }
    [self.bridge splashAd:self didLoadWithExt:extra];
}

/// 广告曝光成功
- (void)splashDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge splashAdWillVisible:self];
}

/// 广告点击
- (void)splashDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge splashAdDidClick:self];
}

/// 广告关闭
- (void)splashDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceSplash = nil;
    [self.bridge splashAdDidClose:self];
}

- (void)dealloc {
    
}

@end
