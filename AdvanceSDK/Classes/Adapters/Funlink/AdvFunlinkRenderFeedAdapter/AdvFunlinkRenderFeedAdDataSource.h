//
//  AdvFunlinkRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <FLinkAdSaas/FLinkAdSaas.h>

@interface AdvFunlinkRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithAdData:(FLinkFeedAdData *)data;

@end
