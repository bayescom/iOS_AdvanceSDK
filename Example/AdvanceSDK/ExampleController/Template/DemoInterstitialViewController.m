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
@property (nonatomic) bool isAdLoaded;
@end

@implementation DemoInterstitialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10000559"},
    ];
    self.btn1Title = @"加载广告";
    self.btn2Title = @"显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    
//    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:@"11111112"
//                                                              viewController:self];

    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId
                                                              viewController:self];
    
//    self.advanceInterstitial = [[AdvanceInterstitial alloc] initWithAdspotId:self.adspotId
//                                                                   customExt:@{@"test" : @"测试自定义拓展参数"}
//                                                              viewController:self];
    self.advanceInterstitial.delegate = self;
    [self.advanceInterstitial setDefaultAdvSupplierWithMediaId:@"100255"
                                                      adspotId:@"10000559"
                                                      mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                         sdkId:SDK_ID_MERCURY];
    _isAdLoaded=false;
    [self.advanceInterstitial loadAd];
}

- (void)loadAdBtn2Action {
    if (!_isAdLoaded) {
       [JDStatusBarNotification showWithStatus:@"请先加载广告" dismissAfter:1.5];
    }
    [self.advanceInterstitial showAd];
}

// MARK: ======================= AdvanceInterstitialDelegate =======================

/// 请求广告数据成功后调用
- (void)advanceInterstitialOnAdReceived {
    NSLog(@"请求广告数据成功后调用");
    _isAdLoaded=true;
    [JDStatusBarNotification showWithStatus:@"广告加载成功" dismissAfter:1.5];

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
- (void)advanceInterstitialOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告拉取失败");
    [JDStatusBarNotification showWithStatus:@"广告加载失败" dismissAfter:1.5];

}

/// 广告关闭
- (void)advanceInterstitialOnAdClosed {
    NSLog(@"广告关闭");
}

/// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId {
    NSLog(@"策略id:%@", reqId);
}


- (void)advanceInterstitialOnReadyToShow {
    if (!_isAdLoaded) {
       [JDStatusBarNotification showWithStatus:@"请先加载广告" dismissAfter:1.5];
    }
    [self.advanceInterstitial showAd];
}


@end
