//
//  AdvSigmobRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <WindSDK/WindSDK.h>

@interface AdvSigmobRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd
                          adView:(WindNativeAdView *)adView;

@end
