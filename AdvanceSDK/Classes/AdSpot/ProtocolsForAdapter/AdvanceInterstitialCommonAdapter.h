//
//  AdvanceInterstitialCommonAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2025/12/08.
//

#import "AdvanceCommonAdapter.h"

@protocol AdvanceInterstitialCommonAdapter <AdvanceCommonAdapter>

@optional

@property (nonatomic, weak) id<AdvanceInterstitialCommonAdapter> delegate;

- (void)interstitialAdapter_didLoadAdWithAdapterId:(NSString *)adapterId price:(NSInteger)price;

- (void)interstitialAdapter_failedToLoadAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)interstitialAdapter_didAdExposuredWithAdapterId:(NSString *)adapterId;

- (void)interstitialAdapter_failedToShowAdWithAdapterId:(NSString *)adapterId error:(NSError *)error;

- (void)interstitialAdapter_didAdClickedWithAdapterId:(NSString *)adapterId;

- (void)interstitialAdapter_didAdClosedWithAdapterId:(NSString *)adapterId;

@end

