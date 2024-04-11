//
//  AdvBiddingInterstitialCustomAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/24.
//

#import "AdvBiddingInterstitialCustomAdapter.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import <AdvanceSDK/AdvanceInterstitial.h>
#import "GroMoreBiddingManager.h"

@interface AdvBiddingInterstitialCustomAdapter () <ABUCustomInterstitialAdapter, AdvanceInterstitialDelegate>

@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;
@property (nonatomic, assign) NSInteger biddingType;
@property (nonatomic, assign) NSInteger price;

@end

@implementation AdvBiddingInterstitialCustomAdapter


- (ABUMediatedAdStatus)mediatedAdStatus {
    return ABUMediatedAdStatusNormal;
}

// Client Bidding的结果回调
- (void)didReceiveBidResult:(ABUMediaBidResult *)result {
    
}

- (void)loadInterstitialAdWithSlotID:(NSString *)slotID andSize:(CGSize)size parameter:(NSDictionary *)parameter {
    
    _biddingType = [[parameter objectForKey:ABUAdLoadingParamBiddingType] integerValue];
    _advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:slotID
                                                                   customExt:nil
                                                              viewController:nil];
    _advanceInterstitial.delegate = self;
    _advanceInterstitial.muted = [parameter[ABUAdLoadingParamISIsMute] boolValue];
    /// 并发加载各个渠道SDK
    [_advanceInterstitial catchBidTargetWhenGroMoreBiddingWithPolicyModel:GroMoreBiddingManager.policyModel];
    
}

- (BOOL)showAdFromRootViewController:(UIViewController *_Nonnull)viewController parameter:(NSDictionary *)parameter {
    [self.advanceInterstitial showAdFromViewController:viewController];
    return YES;
}

#pragma mark: - AdvanceInterstitialDelegate

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {

    [self.bridge interstitialAd:self didLoadFailWithError:error ext:description];
}

- (void)didFinishBiddingADWithSpotId:(NSString *)spotId price:(NSInteger)price {
    self.price = price;
}

/// 广告数据拉取成功
- (void)didFinishLoadingInterstitialADWithSpotId:(NSString *)spotId {
    NSMutableDictionary *extra = [@{} mutableCopy];
    if (self.biddingType == 1) { // client
        NSString *cpm = [NSString stringWithFormat:@"%ld", (long)self.price];
        [extra setObject:cpm forKey:ABUMediaAdLoadingExtECPM];
    }
    [self.bridge interstitialAd:self didLoadWithExt:extra];
}

/// 广告曝光
- (void)interstitialDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge interstitialAdDidVisible:self];
}

/// 广告点击
- (void)interstitialDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    [self.bridge interstitialAdDidClick:self];
}

/// 广告关闭
- (void)interstitialDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceInterstitial = nil;
    [self.bridge interstitialAdDidClose:self];
}

@end
