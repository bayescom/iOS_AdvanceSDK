//
//  AdvCSJRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/11.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <BUAdSDK/BUAdSDK.h>

@interface AdvCSJRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd
                          adView:(BUNativeAdRelatedView *)adView;

@end

