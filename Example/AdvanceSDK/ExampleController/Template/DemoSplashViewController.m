//
//  DemoSplashViewController.m
//  AAA
//
//  Created by CherryKing on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"

#import "DemoUtils.h"

#import <AdvanceSDK/AdvanceSplash.h>

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-100024364312"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"100255-10002619"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101031-10003190"},
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"101245-10003940"},
        @{@"addesc": @"Mock 渠道错误", @"adspotId": @"100255-10000001"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10003321"},
        @{@"addesc": @"Mock code200", @"adspotId": @"100255-10009879"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
//    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"11111112"
//                                                  viewController:self];

    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
                                                  viewController:self];
//    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:self.adspotId
//                                                       customExt:self.ext
//                                                  viewController:self];

    self.advanceSplash.delegate = self;
//    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultAdvSupplierWithMediaId:@"100255"
                                                adspotId:@"10002436"
                                                mediaKey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkId:SDK_ID_MERCURY];
    self.advanceSplash.timeout = 30;
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功 %s", __func__);
}

/// 广告曝光成功
- (void)advanceExposured {
    NSLog(@"广告曝光成功 %s", __func__);
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error {
    NSLog(@"广告展示失败 %s  error: %@", __func__, error);

}

/// 内部渠道开始加载时调用
- (void)advanceSupplierWillLoad:(NSString *)supplierId {
    NSLog(@"内部渠道开始加载 %s  supplierId: %@", __func__, supplierId);

}
/// 广告点击
- (void)advanceClicked {
    NSLog(@"广告点击 %s", __func__);
}

/// 广告关闭
- (void)advanceDidClose {
    NSLog(@"广告关闭了 %s", __func__);
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    NSLog(@"广告倒计时结束 %s", __func__);
}

/// 点击了跳过
- (void)advanceSplashOnAdSkipClicked {
    NSLog(@"点击了跳过 %s", __func__);
}

// 策略请求成功
- (void)advanceOnAdReceived:(NSString *)reqId
{
    NSLog(@"%s 策略id为: %@",__func__ , reqId);
}

@end
