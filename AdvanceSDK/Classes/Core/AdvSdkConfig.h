//
//  AdvSdkConfig.h
//  advancelib
//
//  Created by allen on 2019/9/12.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *const AdvanceSdkAPIVersion;
extern NSString *const AdvanceSdkVersion;
extern NSString *const AdvanceSdkRequestUrl;
extern NSString *const SDK_ID_MERCURY;
extern NSString *const SDK_ID_GDT;
extern NSString *const SDK_ID_CSJ;
extern NSString *const SDK_ID_BAIDU;
extern NSString *const SDK_ID_KS;
extern NSString *const SDK_ID_TANX;
extern NSString *const SDK_ID_Sigmob;

extern NSString *const AdvSdkTypeAdName;
extern NSString *const AdvSdkTypeAdNameSplash;
extern NSString *const AdvSdkTypeAdNameBanner;
extern NSString *const AdvSdkTypeAdNameInterstitial;
extern NSString *const AdvSdkTypeAdNameFullScreenVideo;
extern NSString *const AdvSdkTypeAdNameNativeExpress;
extern NSString *const AdvSdkTypeAdNameRenderFeed;
extern NSString *const AdvSdkTypeAdNameRewardedVideo;

extern NSString *const AdvanceSDKModelKey;
extern NSString *const AdvanceSDKIdfaKey;
extern NSString *const AdvanceSDKIdfvKey;
extern NSString *const AdvanceSDKCarrierKey;
extern NSString *const AdvanceSDKNetworkKey;

extern NSString *const AdvanceSDKOneMonthKey;
extern NSString *const AdvanceSDKHourKey;
extern NSString *const AdvanceSDKSecretKey;


@interface AdvSdkConfig : NSObject

+ (instancetype)shareInstance;

/// SDK版本
+ (NSString *)sdkVersion;

/// appid 从平台获取
@property (nonatomic, copy) NSString *appId;

/// 是否允许个性化广告推送  默认为YES
@property (nonatomic, assign) BOOL isAdTrack;

/// 是否允许打印日志，默认为YES
@property (nonatomic, assign) BOOL logEnable;

@end

NS_ASSUME_NONNULL_END
