//
//  AdvMercuryRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <MercurySDK/MercurySDK.h>

@interface AdvMercuryRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject
                            adView:(MercuryUnifiedNativeAdView *)adView;

@end
