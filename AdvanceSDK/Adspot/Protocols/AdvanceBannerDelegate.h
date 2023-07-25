
#ifndef AdvanceBannerProtocol_h
#define AdvanceBannerProtocol_h
#import "AdvanceAdLoadingDelegate.h"
@protocol AdvanceBannerDelegate <AdvanceAdLoadingDelegate>
@optional

#pragma 请移步AdvanceBaseDelegate
- (void)advanceAdMaterialLoadSuccess;
@end

#endif
