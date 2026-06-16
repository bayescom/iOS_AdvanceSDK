//
//  AdvMercuryRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <MercurySDK/MercurySDK.h>

@interface AdvMercuryRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject;

@end
