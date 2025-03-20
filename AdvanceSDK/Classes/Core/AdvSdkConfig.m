//
//  AdvSdkConfig.m
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import "AdvSdkConfig.h"

@interface AdvSdkConfig ()

@end

@implementation AdvSdkConfig

NSString *const AdvanceSdkAPIVersion = @"3.0";
NSString *const AdvanceSdkVersion = @"5.1.4";
NSString *const AdvanceSdkRequestUrl = @"http://cruiser.bayescom.cn/eleven";
NSString *const SDK_ID_MERCURY = @"1";
NSString *const SDK_ID_GDT = @"2";
NSString *const SDK_ID_CSJ = @"3";
NSString *const SDK_ID_BAIDU = @"4";
NSString *const SDK_ID_KS = @"5";
NSString *const SDK_ID_TANX = @"7";
NSString *const SDK_ID_Sigmob = @"11";

// MARK: ======================= 广告位类型名称 =======================
NSString * const AdvSdkTypeAdName = @"ADNAME";
NSString * const AdvSdkTypeAdNameSplash = @"SPLASH_AD";
NSString * const AdvSdkTypeAdNameBanner = @"BANNER_AD";
NSString * const AdvSdkTypeAdNameInterstitial = @"INTERSTAITIAL_AD";
NSString * const AdvSdkTypeAdNameFullScreenVideo = @"FULLSCREENVIDEO_AD";
NSString * const AdvSdkTypeAdNameNativeExpress = @"NATIVEEXPRESS_AD";
NSString * const AdvSdkTypeAdNameRenderFeed = @"RENDERFEED_AD";
NSString * const AdvSdkTypeAdNameRewardedVideo = @"REWARDEDVIDEO_AD";

// MARK: ======================= NSUserDefaultsKeys =======================
NSString * const AdvanceSDKModelKey = @"AdvanceSDKModelKey";
NSString * const AdvanceSDKIdfaKey = @"AdvanceSDKIdfaKey";
NSString * const AdvanceSDKIdfvKey = @"AdvanceSDKIdfvKey";
NSString * const AdvanceSDKCarrierKey = @"AdvanceSDKCarrierKey";
NSString * const AdvanceSDKNetworkKey = @"AdvanceSDKNetworkKey";

// MARK: ======================= TimeKeys =======================
NSString * const AdvanceSDKTimeOutForeverKey = @"AdvanceSDKTimeOutForeverKey";
NSString * const AdvanceSDKOneMonthKey = @"AdvanceSDKOneMonthKey";
NSString * const AdvanceSDKHourKey = @"AdvanceSDKHourKey";
NSString * const AdvanceSDKSecretKey = @"bayescom1000000w";


static AdvSdkConfig *instance = nil;

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    //dispatch_once （If called simultaneously from multiple threads, this function waits synchronously until the block has completed. 由官方解释，该函数是线程安全的）
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
        instance.isAdTrack = YES;
        instance.logEnable = YES;
    });
    return instance;
}

+ (NSString *)sdkVersion {
    return AdvanceSdkVersion;
}

+ (void)setLogEnable:(BOOL)enable {
    [AdvSdkConfig shareInstance].logEnable = enable;
}

- (NSString *)appId {
    if (!_appId) {
        _appId = @"";
    }
    return _appId;
}

//保证从-alloc-init和-new方法返回的对象是由shareInstance返回的
+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

//保证从copy获取的对象是由shareInstance返回的
- (id)copyWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

//保证从mutableCopy获取的对象是由shareInstance返回的
- (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return [AdvSdkConfig shareInstance];
}

@end
