//
//  ADVANCEAppDelegate.m
//  AdvanceSDK
//
//  Created by Cheng455153666 on 02/27/2020.
//  Copyright (c) 2020 Cheng455153666. All rights reserved.
//

#import "ADVANCEAppDelegate.h"

#import <AdvanceSDK/AdvanceSDK.h>

@interface ADVANCEAppDelegate () <AdvanceSplashDelegate>
@property (nonatomic, strong) AdvanceSplash *advanceSplash;

@end

@implementation ADVANCEAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
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

@end
