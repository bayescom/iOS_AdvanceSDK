
#ifndef AdvanceInterstitialProtocol_h
#define AdvanceInterstitialProtocol_h

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
