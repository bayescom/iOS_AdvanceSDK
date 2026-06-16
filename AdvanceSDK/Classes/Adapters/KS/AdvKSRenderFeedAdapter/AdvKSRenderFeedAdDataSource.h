//
//  AdvKSRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <KSAdSDK/KSAdSDK.h>

@interface AdvKSRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithNativeAdData:(KSMaterialMeta *)data;

@end
