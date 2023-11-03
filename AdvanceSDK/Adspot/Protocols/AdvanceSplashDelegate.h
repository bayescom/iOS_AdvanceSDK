//
//  AdvanceSplashDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceSplashDelegate_h
#define AdvanceSplashDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceSplashDelegate <AdvanceAdLoadingDelegate>

@optional

/// Splash ad loaded successfully
- (void)didFinishLoadingSplashADWithSpotId:(NSString *)spotId;

/// Splash ad displayed successfully
- (void)splashDidShowForSpotId:(NSString *)spotId
                         extra:(NSDictionary *)extra;

/// Splash ad clicked
- (void)splashDidClickForSpotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;

/// Splash ad closed
- (void)splashDidCloseForSpotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;

@end

#endif 
