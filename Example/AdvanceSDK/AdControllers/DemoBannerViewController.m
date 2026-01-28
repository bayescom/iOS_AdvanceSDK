//
//  DemoBannerViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoBannerViewController.h"
#import <AdvanceSDK/AdvanceBanner.h>

@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner *bannerAd;
@property (nonatomic, strong) UIView *bannerAdView;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.adShowView.hidden = NO;
    self.adspotIdsArr = @[
        @{@"addesc": @"横幅-Bidding", @"adspotId": @"102768-10008517"},
        @{@"addesc": @"横幅-倍业", @"adspotId": @"102768-10007790"},
        @{@"addesc": @"横幅-穿山甲", @"adspotId": @"102768-10007800"},
        @{@"addesc": @"横幅-优量汇", @"adspotId": @"102768-10007809"},
    ];
    self.btn1Title = @"加载并展示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    [_bannerAdView removeFromSuperview];
    
    _bannerAd = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId extra:self.ext delegate:self];
    _bannerAd.adSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.width * 5.0 / 32.0);
    _bannerAd.viewController = self;
    [_bannerAd loadAd];
}


#pragma mark: - AdvanceInterstitialDelegate
/// 广告加载成功回调
- (void)onBannerAdDidLoad:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告加载成功 %s %@", __func__, bannerAd);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:0.7];
    if (bannerAd.isAdValid) {
        self.bannerAdView = bannerAd.bannerView;
        [self.adShowView addSubview:self.bannerAdView];
    }
}

/// 广告加载失败回调
-(void)onBannerAdFailToLoad:(AdvanceBanner *)bannerAd error:(NSError *)error {
    NSLog(@"横幅广告加载失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:0.7];
    self.bannerAd = nil;
}

/// 广告曝光回调
-(void)onBannerAdExposured:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告曝光回调 %s %@", __func__, bannerAd);
}

/// 广告展示失败回调
-(void)onBannerAdFailToPresent:(AdvanceBanner *)bannerAd error:(NSError *)error {
    NSLog(@"横幅广告展示失败 %s %@", __func__, error);
    [JDStatusBarNotification showWithStatus:@"广告展示失败" dismissAfter:0.7];
    self.bannerAd = nil;
}

/// 广告点击回调
- (void)onBannerAdClicked:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告点击回调 %s %@", __func__, bannerAd);
}

/// 广告关闭回调
- (void)onBannerAdClosed:(AdvanceBanner *)bannerAd {
    NSLog(@"横幅广告关闭回调 %s %@", __func__, bannerAd);
    self.bannerAd = nil;
    [self.bannerAdView removeFromSuperview];
}

- (void)dealloc {
    
}

@end
