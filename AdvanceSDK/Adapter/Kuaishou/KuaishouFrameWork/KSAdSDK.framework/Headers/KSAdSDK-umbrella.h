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

#import "KSAdExportManager.h"
#import "KSDrawAd.h"
#import "KSDrawAdsManager.h"
#import "KSFeedAd.h"
#import "KSFeedAdsManager.h"
#import "KSInterstitialAd.h"
#import "KSAdImage.h"
#import "KSMaterialMeta.h"
#import "KSNativeAd.h"
#import "KSNativeAdRelatedView.h"
#import "KSNativeAdsManager.h"
#import "KSAdSplashDelegate.h"
#import "KSAdSplashInteractDelegate.h"
#import "KSAdSplashManager.h"
#import "KSAdSplashViewController.h"
#import "KSSplashAdView.h"
#import "KSAdPlayableDemoViewController.h"
#import "KSAdShowDirection.h"
#import "KSFullscreenVideoAd.h"
#import "KSRewardedVideoAd.h"
#import "KSRewardedVideoModel.h"
#import "KSVideoAd.h"
#import "KSAdBasePlayerView.h"
#import "KSAdPlayerView.h"
#import "KSVideoAdView.h"
#import "KSAdUserInfo.h"
#import "KSAd.h"
#import "KSAdPos.h"
#import "KSAdSDK.h"
#import "KSAdSDKError.h"
#import "KSAdSDKManager.h"
#import "KSCUEntryElement.h"
#import "KSCUFeedPage.h"
#import "KSCUFeedPageScrollViewDelegate.h"
#import "KSCUHorizontalFeed.h"
#import "KSCUImageTextFeed.h"
#import "KSCUCallBackProtocol.h"
#import "KSCUFeedEvent.h"
#import "KSCUHotspotPage.h"
#import "KSCUOuterController.h"
#import "KSCUEmbedAdConfig.h"
#import "KSCUContentPage.h"
#import "KSCUContentPageDelegate.h"

FOUNDATION_EXPORT double KSAdSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char KSAdSDKVersionString[];

