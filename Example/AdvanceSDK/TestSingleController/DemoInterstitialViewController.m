//
//  DemoInterstitialViewController.m
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "DemoInterstitialViewController.h"
#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSDK.h>

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
    self.advanceInterstitial.delegate=self;
    [self.advanceInterstitial setDefaultSdkSupplierWithMediaId:@"100255"
                                                      adspotid:@"10000559"
                                                      mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                        sdkTag:SDK_TAG_MERCURY];
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================
- (void)advanceInterstitialOnAdReady {
    [DemoUtils showToast:@"广告就绪"];
}

- (void)advanceInterstitialOnAdClicked {
    [DemoUtils showToast:@"广告点击"];
}

- (void)advanceInterstitialOnAdFailed {
    [DemoUtils showToast:@"广告失败"];
}

- (void)advanceInterstitialOnAdShow {
    [DemoUtils showToast:@"广告展示"];
}

- (void)advanceInterstitialOnAdClosed {
    [DemoUtils showToast:@"广告关闭"];
}


@end
