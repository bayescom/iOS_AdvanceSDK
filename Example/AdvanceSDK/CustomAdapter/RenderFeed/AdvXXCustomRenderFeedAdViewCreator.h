//
//  AdvXXCustomRenderFeedAdViewCreator.h
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/18.
//  Copyright © 2026. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvRenderFeedAdViewCreator.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvXXCustomRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithNativeAd:(BUNativeAd *)nativeAd
                          adView:(BUNativeAdRelatedView *)adView;

@end

NS_ASSUME_NONNULL_END
