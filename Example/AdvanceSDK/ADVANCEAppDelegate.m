//
//  ADVANCEAppDelegate.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "ADVANCEAppDelegate.h"

#import <AdvanceSDK/AdvanceSDK.h>
#import "ADVANCEViewController.h"

@interface ADVANCEAppDelegate () <AdvanceSplashDelegate>
@property (nonatomic, strong) AdvanceSplash *advanceSplash;

@end

@implementation ADVANCEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ADVANCEViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [[AdvanceSdkConfig shareInstance] setConfig:@{
        AdvanceSDKConfigMercuryAppID: @"100255",
        AdvanceSDKConfigMercuryMediaKey: @"757d5119466abe3d771a211cc1278df7",
        AdvanceSDKConfigMercuryOpenDebug: @(YES),

        AdvanceSDKConfigBUAppID: @"5000546",
        AdvanceSDKConfigBULogLevel: @(AdvanceSDKConfigBULogLevelDebug),
        AdvanceSDKConfigBUIsPaidApp: @(NO),

        AdvanceSDKConfigGDTEnableGPS: @(YES),
    }];
    
    [self splashShow];
    
    return YES;
}

- (void)splashShow {   // 开屏
    self.advanceSplash = [[AdvanceSplash alloc] initWithMediaId:@"10033"
                                                       adspotId:@"200034"
                                                 viewController:self.window.rootViewController];
    self.advanceSplash.delegate=self;
    self.advanceSplash.logoImage= [UIImage imageNamed:@"640-100"];
    self.advanceSplash.backgroundImage= [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"100255"
                                                adspotid:@"10002436"
                                                mediakey:@"757d5119466abe3d771a211cc1278df7"
                                                  sdkTag:SDK_TAG_MERCURY];
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/// 广告数据拉取成功
- (void)advanceSplashOnAdReceived {
    NSLog(@"广告数据拉取成功");
}

/// 广告渲染失败
- (void)advanceSplashOnAdRenderFailed {
    NSLog(@"广告渲染失败");
}

/// 广告曝光成功
- (void)advanceSplashOnAdShow {
    NSLog(@"广告曝光成功");
}

/// 广告展示失败
- (void)advanceSplashOnAdFailed {
    NSLog(@"广告展示失败");
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
