
#ifndef AdvanceSplashProtocol_h
#define AdvanceSplashProtocol_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceSplashDelegate <AdvanceAdLoadingDelegate>

@optional

/// Splash ad is loaded successfully
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId;

/// Splash ad is displayed successfully
- (void)splashDidShowForSpotId:(NSString *)spotId
                         extra:(NSDictionary *)extra;

/// Splash ad click
- (void)splashDidClickForSpotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;

/// Splash ad closed
- (void)splashDidCloseForSpotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;


///MARK: DEPRECATED Callback
/// 广告点击跳过
- (void)advanceSplashOnAdSkipClicked DEPRECATED_MSG_ATTRIBUTE("该回调已经被废弃");

/// 广告倒计时结束回调
- (void)advanceSplashOnAdCountdownToZero DEPRECATED_MSG_ATTRIBUTE("该回调已经被废弃, 请在 -splashDidCloseForSpotId:extra: 中处理关闭时相关业务");

@end

#endif 
