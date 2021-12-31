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
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@interface AppDelegate () <AdvanceSplashDelegate>
@property(strong,nonatomic) AdvanceSplash *advanceSplash;

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    
    
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma 开始集成前 请务必阅读文档中的注意事项及Checklist https://github.com/bayescom/AdvanceSDK
#pragma Demo 中有许多内容为开发调试的内容, 仅作为开发者调试自己的账号使用, 不一定会出广告

    // 请现在 plist 文件中配置 NSUserTrackingUsageDescription
    /*
     <key>NSUserTrackingUsageDescription</key>
     <string>该ID将用于向您推送个性化广告</string>
     */
    // 项目需要适配http
    
    /*
     <key>NSAppTransportSecurity</key>
     <dict>
         <key>NSAllowsArbitraryLoads</key>
         <true/>
     </dict>
     */
    // 调试阶段尽量用真机, 以便获取idfa, 如果获取不到idfa, 则打开idfa开关
    // iphone 打开idfa 开关的的过程:设置 -> 隐私 -> 跟踪 -> 允许App请求跟踪
    __block NSString *idfa = @"";
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                idfa = [[manager advertisingIdentifier] UUIDString];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // do something
                [AdvSdkConfig shareInstance].level = AdvLogLevel_Debug;
//                [AdvSdkConfig shareInstance].appId = @"100255";
//                [self loadSplash];
            });
        }];
    }else{
        if ([manager isAdvertisingTrackingEnabled]) {
            idfa = [[manager advertisingIdentifier] UUIDString];
//            [AdvSdkConfig shareInstance].appId = @"100255";
//            [self loadSplash];
        }

    }
    
    return YES;
}

- (void)loadSplash {
    // 测试使用 很容易不出广告
    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"10002619"
//    self.advanceSplash = [[AdvanceSplash alloc] initWithAdspotId:@"20000003"
                                                  viewController:self.window.rootViewController];
    self.advanceSplash.delegate = self;
//    self.advanceSplash.showLogoRequire = YES;
    self.advanceSplash.logoImage = [UIImage imageNamed:@"app_logo"];
    self.advanceSplash.backgroundImage = [UIImage imageNamed:@"LaunchImage_img"];
    self.advanceSplash.timeout = 5;
    [self.advanceSplash loadAd];
}

// MARK: ======================= AdvanceSplashDelegate =======================
/**
 */
/// 广告数据拉取成功
- (void)advanceUnifiedViewDidLoad {
    NSLog(@"广告数据拉取成功 %s", __func__);
}

/// 广告曝光成功
- (void)advanceExposured {
    NSLog(@"广告曝光成功 %s", __func__);
}

/// 广告加载失败
- (void)advanceFailedWithError:(NSError *)error description:(NSDictionary *)description{
    NSLog(@"广告展示失败 %s  error: %@ 详情:%@", __func__, error, description);

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
