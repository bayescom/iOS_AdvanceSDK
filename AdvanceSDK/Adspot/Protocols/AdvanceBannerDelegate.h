//
//  AdvanceBannerDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceBannerDelegate_h
#define AdvanceBannerDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@protocol AdvanceBannerDelegate <AdvanceAdLoadingDelegate>

@optional

/// Banner ad loaded successfully
- (void)didFinishLoadingBannerADWithSpotId:(NSString *)spotId;

/// Banner ad displayed
- (void)bannerView:(UIView *)bannerView didShowAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra;

/// Banner ad clicked
- (void)bannerView:(UIView *)bannerView didClickAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra;

/// Banner ad closed
- (void)bannerView:(UIView *)bannerView didCloseAdWithSpotId:(NSString *)spotId extra:(NSDictionary *)extra;


@end

#endif
