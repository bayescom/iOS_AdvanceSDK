//
//  AdvanceInterstitialDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceInterstitialDelegate_h
#define AdvanceInterstitialDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceInterstitialDelegate <AdvanceAdLoadingDelegate>

@optional

/// Interstitial ad loaded successfully
- (void)didFinishLoadingInterstitialADWithSpotId:(NSString *)spotId;

/// Interstitial ad displayed successfully
- (void)interstitialDidShowForSpotId:(NSString *)spotId
                               extra:(NSDictionary *)extra;

/// Interstitial ad clicked
- (void)interstitialDidClickForSpotId:(NSString *)spotId
                                extra:(NSDictionary *)extra;

/// Interstitial ad closed
- (void)interstitialDidCloseForSpotId:(NSString *)spotId
                                extra:(NSDictionary *)extra;

@end

#endif
