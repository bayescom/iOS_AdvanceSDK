#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "AdvanceBanner.h"
#import "AdvanceFullScreenVideo.h"
#import "AdvanceInterstitial.h"
#import "AdvanceNativeExpress.h"
#import "AdvanceRewardVideo.h"
#import "AdvanceSplash.h"
#import "AdvanceBannerDelegate.h"
#import "AdvanceFullScreenVideoDelegate.h"
#import "AdvanceInterstitialDelegate.h"
#import "AdvanceNativeExpressDelegate.h"
#import "AdvanceRewardVideoDelegate.h"
#import "AdvanceSplashDelegate.h"
#import "CsjBannerAdapter.h"
#import "CsjFullScreenVideoAdapter.h"
#import "CsjInterstitialAdapter.h"
#import "CsjNativeExpressAdapter.h"
#import "CsjRewardVideoAdapter.h"
#import "CsjSplashAdapter.h"
#import "AdvanceBaseAdspot.h"
#import "AdvanceSDK.h"
#import "AdvanceSdkConfig.h"
#import "UIApplication+Advance.h"
#import "SdkReportData.h"
#import "SdkSupplier.h"
#import "AdvanceDeviceInfoUtil.h"
#import "AdvanceLog.h"
#import "GdtBannerAdapter.h"
#import "GdtFullScreenVideoAdapter.h"
#import "GdtInterstitialAdapter.h"
#import "GdtNativeExpressAdapter.h"
#import "GdtRewardVideoAdapter.h"
#import "GdtSplashAdapter.h"
#import "MercuryBannerAdapter.h"
#import "MercuryInterstitialAdapter.h"
#import "MercuryNativeExpressAdapter.h"
#import "MercuryRewardVideoAdapter.h"
#import "MercurySplashAdapter.h"

FOUNDATION_EXPORT double AdvanceSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char AdvanceSDKVersionString[];

