//
//  DemoInterstitialViewController.m
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "DemoInterstitialViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceInterstitial.h>

@interface DemoInterstitialViewController () <AdvanceInterstitialDelegate>
@property (nonatomic, strong) AdvanceInterstitial *advanceInterstitial;

@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200043"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithMediaId:self.mediaId
                                                                   adspotId:self.adspotId
                                                             viewController:self];
    self.advanceInterstitial.delegate = self;
    [self.advanceInterstitial setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotid:@"10000559"
                                                      mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkTag:@"bayes"];
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceInterstitialOnAdReceived {
    NSLog(@"请求广告数据成功后调用");
}

/// 广告渲染失败
- (void)advanceInterstitialOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

/// 广告曝光成功
- (void)advanceInterstitialOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告点击
- (void)advanceInterstitialOnAdClicked {
    NSLog(@"广告点击");
}

/// 广告拉取失败
- (void)advanceInterstitialOnAdFailedWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    NSLog(@"广告拉取失败");
}

/// 广告关闭
- (void)advanceInterstitialOnAdClosed {
    NSLog(@"广告关闭");
}


@end
