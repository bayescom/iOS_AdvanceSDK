#import "AdvDeviceManager.h"
#import "NSMutableDictionary+Adv.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import "AdvDefines.h"
#import "NSArray+Adv.h"
#import "AdvSupplierLoader.h"
#import "AdvAdConfigHeader.h"

#ifndef AdvConstantHeader_h
#define AdvConstantHeader_h

static NSString *const AdvanceSDKAPIVersion = @"3.0";
static NSString *const AdvanceSDKVersion = @"3.0.0";
static NSString *const AdvanceSDKRequestUrl = @"http://cruiser.bayescom.cn/";
static NSString *const AdvanceSDKSecretKey = @"bayescom1000000w";

static NSString *const SDK_ID_MERCURY = @"1";
static NSString *const SDK_ID_GDT = @"2";
static NSString *const SDK_ID_CSJ = @"3";
static NSString *const SDK_ID_BAIDU = @"4";
static NSString *const SDK_ID_KS = @"5";
static NSString *const SDK_ID_TANX = @"7";
static NSString *const SDK_ID_Sigmob = @"11";

// MARK: ======================= 广告位类型名称 =======================
static NSString * const AdvSdkTypeAdName = @"ADNAME";
static NSString * const AdvSdkTypeAdNameSplash = @"SPLASH_AD";
static NSString * const AdvSdkTypeAdNameBanner = @"BANNER_AD";
static NSString * const AdvSdkTypeAdNameInterstitial = @"INTERSTAITIAL_AD";
static NSString * const AdvSdkTypeAdNameFullScreenVideo = @"FULLSCREENVIDEO_AD";
static NSString * const AdvSdkTypeAdNameNativeExpress = @"NATIVEEXPRESS_AD";
static NSString * const AdvSdkTypeAdNameRenderFeed = @"RENDERFEED_AD";
static NSString * const AdvSdkTypeAdNameRewardVideo = @"REWARDVIDEO_AD";

#endif
