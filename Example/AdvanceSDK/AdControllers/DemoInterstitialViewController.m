//
//  DemoInterstitialViewController.m
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "DemoInterstitialViewController.h"
#import <AdvanceSDK/AdvanceInterstitial.h>

@interface DemoInterstitialViewController () <AdvanceInterstitialDelegate>
@property (nonatomic, strong) AdvanceInterstitial *interstitialAd;
@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adspotIdsArr = @[
        //@{@"addesc": @"插屏-GroMore", @"adspotId": @"102768-10008588"},
        @{@"addesc": @"插屏-Bidding", @"adspotId": @"102768-10008520"},
        @{@"addesc": @"插屏-倍业", @"adspotId": @"102768-10007791"},
        @{@"addesc": @"插屏-穿山甲", @"adspotId": @"102768-10007801"},
        @{@"addesc": @"插屏-优量汇", @"adspotId": @"102768-10007810"},
        @{@"addesc": @"插屏-快手", @"adspotId": @"102768-10007818"},
        @{@"addesc": @"插屏-百度", @"adspotId": @"102768-10007836"},
        @{@"addesc": @"插屏-Tanx", @"adspotId": @"102768-10009460"},
        @{@"addesc": @"插屏-Sigmob", @"adspotId": @"102768-10011980"}
    ];
    self.btn1Title = @"加载并展示广告";
//    self.btn2Title = @"展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.interstitialAd = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId extra:nil delegate:self];
    // 加载广告
    [self.interstitialAd loadAd];
}

- (void)showAd {
    if (self.interstitialAd.isAdValid) {
        [self.interstitialAd showAdFromViewController:self];
    }
}

#pragma mark: - AdvanceInterstitialDelegate
/// 广告加载成功回调
- (void)onInterstitialAdDidLoad:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告加载成功 %s %@", __func__, interstitialAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    [self showAd];
}

/// 广告加载失败回调
-(void)onInterstitialAdFailToLoad:(AdvanceInterstitial *)interstitialAd error:(NSError *)error {
    NSLog(@"插屏广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.interstitialAd = nil;
}

/// 广告曝光回调
-(void)onInterstitialAdExposured:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告曝光回调 %s %@", __func__, interstitialAd);
}

/// 广告展示失败回调
-(void)onInterstitialAdFailToPresent:(AdvanceInterstitial *)interstitialAd error:(NSError *)error {
    NSLog(@"插屏广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.interstitialAd = nil;
}

/// 广告点击回调
- (void)onInterstitialAdClicked:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告点击回调 %s %@", __func__, interstitialAd);
}

/// 广告关闭回调
- (void)onInterstitialAdClosed:(AdvanceInterstitial *)interstitialAd {
    NSLog(@"插屏广告关闭回调 %s %@", __func__, interstitialAd);
    self.interstitialAd = nil;
}

- (void)dealloc {

}
@end
