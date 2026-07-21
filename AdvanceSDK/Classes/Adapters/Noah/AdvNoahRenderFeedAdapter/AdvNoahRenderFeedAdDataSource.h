//
//  AdvNoahRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/7/17.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <NoahSDK/NoahSDK.h>

@interface AdvNoahRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithAdAssets:(NAAdAssets *)adAssets;

@end
