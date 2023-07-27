//
//  DemoBannerViewController.m
//  Example
//
//  Created by CherryKing on 2019/11/8.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoBannerViewController.h"
#import "ViewBuilder.h"
#import "AdvSdkConfig.h"
#import <AdvanceSDK/AdvanceBanner.h>
@interface DemoBannerViewController () <AdvanceBannerDelegate>
@property (nonatomic, strong) AdvanceBanner *advanceBanner;
@property (nonatomic, strong) UIView *contentV;

@end

@implementation DemoBannerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"Banner", @"adspotId": @"100255-10000558"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    if (!_contentV) {
        _contentV = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.width*5/32.0)];
        _contentV.backgroundColor = [UIColor redColor];
    }
//    [self.adShowView addSubview:self.contentV];
//    self.adShowView.hidden = NO;

//    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:@"11111113" adContainer:self.contentV viewController:self];
//    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.contentV viewController:self];
    self.advanceBanner = [[AdvanceBanner alloc] initWithAdspotId:self.adspotId adContainer:self.contentV customExt:self.ext viewController:self];
    self.advanceBanner.delegate = self;
    self.advanceBanner.refreshInterval = 30;

    
    
    [self.advanceBanner loadAd];
    
}

// MARK: ======================= AdvanceBannerDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略加载失败
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// Banner广告数据拉取成功
- (void)didFinishLoadingBannerADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [self.advanceBanner showAd];
    [self.adShowView addSubview:self.contentV];
    self.adShowView.hidden = NO;
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
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

@end
