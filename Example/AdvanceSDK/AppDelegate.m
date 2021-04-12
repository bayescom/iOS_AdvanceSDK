//
//  AppDelegate.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "AppDelegate.h"

// DEBUG
//#import <STDebugConsole.h>
//#import <STDebugConsoleViewController.h>
//#import <JPFPSStatus.h>

#import "ViewController.h"

#import <AdvanceSplash.h>

#import <AdvanceSDK/AdvanceSplash.h>
#import <AdvSdkConfig.h>

#define kPublicKey  @"用文本编辑打开pub_for_sdk.cer即可获取"

#define kPublicForApiKey @"用文本编辑打开public_for_api.pem即可获取"

#define kDevId @""

@interface AppDelegate () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AdvSdkConfig shareInstance].isDebug = YES;
    [AdvSdkConfig shareInstance].appId = @"100255";
    
    // 冷启动 监听
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        
        // DEBUG
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
//            [self debugConf];
        });
        
        //初始化开屏广告
//        [self loadSplash];
    }];
    
    // 热启动 监听
    [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
        //初始化开屏广告
//        [self loadSplash];
    }];
    
    return YES;
}

- (void)loadSplash {
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"100255"
//    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"20000003"
                                                  viewController:self.window.rootViewController];
    self.advanceSplash.delegate = self;
//    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    [self.advanceSplash setDefaultAdvSupplierWithMediaId:@"100255"
                                                adspotId:@"10004237"
                                                mediaKey:@"c6f80c078b7956821ebdaad72779cffc"
                                                  sdkId:SDK_ID_CSJ];
    self.advanceSplash.timeout = 5;
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


// MARK: ======================= Debug =======================
//- (void)debugConf {
//    [STDebugConsole setModel:STDebugConsoleModelRedirect];
//
//    UIButton *logBtn = [[UIButton alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-50-8, [UIScreen mainScreen].bounds.size.height-50-28, 50, 50)];
//    logBtn.backgroundColor = [UIColor colorWithRed:0.44 green:0.81 blue:0.89 alpha:1.00];
//    [logBtn setTitle:@"日志" forState:UIControlStateNormal];
//    [logBtn setTitleColor:[UIColor colorWithWhite:0.1 alpha:0.3] forState:UIControlStateNormal];
//    logBtn.layer.cornerRadius = 25;
//    [[UIApplication sharedApplication].keyWindow addSubview:logBtn];
//
//    [logBtn addTarget:self action:@selector(showDebug) forControlEvents:UIControlEventTouchUpInside];
//}
//
//- (void)showDebug {
//    STDebugConsoleViewController *vc = [[STDebugConsoleViewController alloc] init];
//    UINavigationController *navc = [[UINavigationController alloc] initWithRootViewController:vc];
////    navc.navigationBarHidden = YES;
//    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:navc animated:YES completion:nil];
//
//    [[JPFPSStatus sharedInstance] open];
//}

@end
