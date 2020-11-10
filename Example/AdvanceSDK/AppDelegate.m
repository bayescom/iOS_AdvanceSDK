//
//  AppDelegate.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "AppDelegate.h"

#import <AdvanceSDK/AdvanceSDK.h>
#import "ViewController.h"

#import <MercurySDK/MercurySDK.h>
#import <BUAdSDK/BUAdSDK.h>
#import <GDTSDKConfig.h>

#import <AdvanceSDK/AdvanceSplash.h>

@interface AppDelegate () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    // 初始化各渠道SDK
    
//     MercurySDK
    [MercuryConfigManager setAppID:@"100255"
                          mediaKey:@"757d5119466abe3d771a211cc1278df7"];
    // 穿山甲SDK
    [BUAdSDKManager setAppID:@"5000546"];
    // 广点通SDK
    [GDTSDKConfig registerAppId:@"1105344611"];
    
    [self loadAdBtn1Action];
    
    return YES;
}

- (void)loadAdBtn1Action {
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"10002619"
                                                  viewController:self.window.rootViewController];
    self.advanceSplash.delegate = self;
//    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultSdkSupplierWithMediaId:@"5000546"
                                                adspotId:@"800546808"
                                                mediaKey:@""
                                                  sdkId:SDK_ID_CSJ];
    self.advanceSplash.timeout = 3;
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
- (void)advanceSplashOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error {
    NSLog(@"广告展示失败(%@):%@", sdkId, error);
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
