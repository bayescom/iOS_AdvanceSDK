//
//  AdvGDTRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <GDTMobSDK/GDTMobSDK.h>

@interface AdvGDTRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject;
                           
@end
