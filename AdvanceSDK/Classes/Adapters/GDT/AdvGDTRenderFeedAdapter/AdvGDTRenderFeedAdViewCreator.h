//
//  AdvGDTRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <GDTMobSDK/GDTMobSDK.h>

@interface AdvGDTRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject
                            adView:(GDTUnifiedNativeAdView *)adView;

@end
