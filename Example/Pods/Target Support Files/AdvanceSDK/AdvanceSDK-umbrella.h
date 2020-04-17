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

#import "AdvanceBaseAdspot.h"
#import "AdvanceSDK.h"
#import "AdvanceSdkConfig.h"
#import "UIApplication+Advance.h"
#import "SdkReportData.h"
#import "SdkSupplier.h"
#import "AdvanceDeviceInfoUtil.h"
#import "AdvanceLog.h"

FOUNDATION_EXPORT double AdvanceSDKVersionNumber;
FOUNDATION_EXPORT const unsigned char AdvanceSDKVersionString[];

