//
//  AdvNoahRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <NoahSDK/NoahSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvNoahRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithNativeAd:(NativeAd *)nativeAd;

@end

NS_ASSUME_NONNULL_END
