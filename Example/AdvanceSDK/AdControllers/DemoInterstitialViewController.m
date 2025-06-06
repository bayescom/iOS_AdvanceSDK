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
@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;
@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10000559"},
//        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10006501"},
        
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
    
    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId
                                                                   customExt:nil
                                                              viewController:self];
    self.advanceInterstitial.delegate = self;
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    if (self.advanceInterstitial.isAdValid) {
        [self.advanceInterstitial showAd];
    }
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 广告策略加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId {
    NSLog(@"%s 广告位id为: %@",__func__ , spotId);
}

/// 广告策略或者渠道广告加载失败
- (void)didFailLoadingADSourceWithSpotId:(NSString *)spotId error:(NSError *)error description:(NSDictionary *)description {
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);
}

/// 广告位中某一个广告源开始加载广告
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId sourceId:(NSString *)sourceId {
    NSLog(@"广告位中某一个广告源开始加载广告 %s  sourceId: %@", __func__, sourceId);
}

/// 插屏广告数据拉取成功
- (void)didFinishLoadingInterstitialADWithSpotId:(NSString *)spotId {
    NSLog(@"广告数据拉取成功 %s", __func__);
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];
    [self loadAdBtn2Action];
}

/// 广告曝光
- (void)interstitialDidShowForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告曝光回调 %s", __func__);
}

/// 广告点击
- (void)interstitialDidClickForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)interstitialDidCloseForSpotId:(NSString *)spotId extra:(NSDictionary *)extra {
    self.advanceInterstitial = nil;
    NSLog(@"广告关闭了 %s", __func__);
}


- (void)dealloc {
    NSLog(@"%s",__func__);

}

@end
