//
//  AdvFunlinkRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvFunlinkRenderFeedAdView.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvFunlinkRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithManager:(FLinkNativeManager *)manager
                           data:(FLinkFeedAdData *)data
                         adView:(AdvFunlinkRenderFeedAdView *)adView;

@end

NS_ASSUME_NONNULL_END
