//
//  DemoSplashViewController.m
//  AAA
//
//  Created by 程立卿 on 2019/11/1.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import "DemoSplashViewController.h"

#import "DemoUtils.h"

#import "AdvanceSDK.h"

@interface DemoSplashViewController () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;
@end

@implementation DemoSplashViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.initDefSubviewsFlag = YES;
    self.adspotIdsArr = @[
        @{@"addesc": @"mediaId-adspotId", @"adspotId": @"10033-200034"},
    ];
    self.btn1Title = @"加载并显示广告";
}

- (void)loadAdBtn1Action {
    if (![self checkAdspotId]) { return; }
    self.advanceSplash = [[AdvanceSplash alloc] initWithMediaId:self.mediaId
                                                       adspotId:self.adspotId
                                                 viewController:self];
    self.advanceSplash.delegate = self;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotid:@"10002436"
                                                mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_TAG_MERCURY];
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
//    NSLog(@"广告数据拉取成功"];
    NSLog(@"广告数据拉取成功");
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告展示失败
- (void)advanceSplashOnAdFailedWithAdapterId:(NSString *)adapterId error:(NSError *)error {
    NSLog(@"广告展示失败(%@):%@", adapterId, error);
}

/// 广告点击
- (void)advanceSplashOnAdClicked {
    NSLog(@"广告点击");
}

/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked {
    NSLog(@"广告点击跳过");
}

/// 广告倒计时结束
- (void)advanceSplashOnAdCountdownToZero {
    NSLog(@"广告倒计时结束");
}

@end
