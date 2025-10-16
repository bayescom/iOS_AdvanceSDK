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
@property (nonatomic, strong) AdvanceBanner *advanceBanner;
@property (nonatomic, strong) UIView *bannerAdView;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
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
    _bannerAdView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/32.0)];

    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.bannerAdView customExt:self.ext viewController:self];
    self.advanceBanner.delegate = self;
    self.advanceBanner.refreshInterval = 30;

    [self.advanceBanner loadAd];
    
}

// MARK: ======================= AdvanceBannerDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// Banner广告数据拉取成功
- (void)didFinishLoadingBannerADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    if (self.advanceBanner.isAdValid) {
        [self.advanceBanner showAd];
    }
    [self.adShowView addSubview:self.bannerAdView];
}

/// 广告曝光
- (void)bannerView:(UIView *)bannerView didShowAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)bannerView:(UIView *)bannerView didClickAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)bannerView:(UIView *)bannerView didCloseAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告关闭了 %s", __func__);
    [bannerView removeFromSuperview];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
