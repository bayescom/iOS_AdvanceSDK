//
//  AdvanceNativeExpressDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceNativeExpressDelegate_h
#define AdvanceNativeExpressDelegate_h

#import "AdvanceAdLoadingDelegate.h"

@class AdvanceNativeExpressAd;

@protocol AdvanceNativeExpressDelegate <AdvanceAdLoadingDelegate>

@optional

/// Native ad loaded successfully
- (void)didFinishLoadingNativeExpressAds:(NSArray <AdvanceNativeExpressAd *>*)nativeAds
                                  spotId:(NSString *)spotId;

/// Native adview rendered successfully
- (void)nativeExpressAdViewRenderSuccess:(AdvanceNativeExpressAd *)nativeAd
                                  spotId:(NSString *)spotId
                                   extra:(NSDictionary *)extra;

/// Native adview failed to render
- (void)nativeExpressAdViewRenderFail:(AdvanceNativeExpressAd *)nativeAd
                               spotId:(NSString *)spotId
                                extra:(NSDictionary *)extra;

/// Native ad displayed successfully
- (void)didShowNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd
                        spotId:(NSString *)spotId
                         extra:(NSDictionary *)extra;

/// Native ad clicked
- (void)didClickNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd
                         spotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;

/// Native ad closed
- (void)didCloseNativeExpressAd:(AdvanceNativeExpressAd *)nativeAd
                         spotId:(NSString *)spotId
                          extra:(NSDictionary *)extra;

@end

#endif


