//
//  AdvSigmobRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <WindSDK/WindSDK.h>

@interface AdvSigmobRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithNativeAd:(WindNativeAd *)nativeAd;

@end

