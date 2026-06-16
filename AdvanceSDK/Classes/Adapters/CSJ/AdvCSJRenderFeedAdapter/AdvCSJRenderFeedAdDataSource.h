//
//  AdvCSJRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <BUAdSDK/BUAdSDK.h>

@interface AdvCSJRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithNativeAdData:(BUMaterialMeta *)data;

@end
