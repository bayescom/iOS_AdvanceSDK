//
//  AdvKSRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <KSAdSDK/KSAdSDK.h>

@interface AdvKSRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithNativeAd:(KSNativeAd *)nativeAd
                          adView:(KSNativeAdRelatedView *)adView;

@end

