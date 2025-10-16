//
//  AppDelegate.m
//  AdvanceSDK
//
//  Created by Bayes on 02/27/2020.
//  Copyright (c) 2020 bayescom. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <AdvanceSDK/AdvSdkConfig.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <AdSupport/AdSupport.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UIViewController *vc = [[ViewController alloc] init];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.translucent = NO;
    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        appearance.backgroundEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleRegular];
        appearance.backgroundColor = [UIColor whiteColor];
        nav.navigationBar.scrollEdgeAppearance = appearance;
        nav.navigationBar.standardAppearance = appearance;
    }
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [AdvSdkConfig shareInstance].appId = @"102768";
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     请在 plist 文件中配置 NSUserTrackingUsageDescription
     <key>NSUserTrackingUsageDescription</key>
     <string>此标识符将用于向您推荐个性化广告</string>
     */
    /*
     项目需要适配http访问
     <key>NSAppTransportSecurity</key>
     <dict>
         <key>NSAllowsArbitraryLoads</key>
         <true/>
     </dict>
     */
    // 调试阶段尽量用真机, 以便获取idfa, 如果获取不到idfa, 则打开idfa开关
    // iphone 打开idfa 开关的的步骤:设置 -> 隐私 -> 跟踪 -> 允许App请求跟踪
    __block NSString *idfa = @"";
    ASIdentifierManager *manager = [ASIdentifierManager sharedManager];
    if (@available(iOS 14, *)) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
            if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
                idfa = [[manager advertisingIdentifier] UUIDString];
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                // do something
            });
        }];
    }else{
        if ([manager isAdvertisingTrackingEnabled]) {
            idfa = [[manager advertisingIdentifier] UUIDString];
        }
    }
}


@end
