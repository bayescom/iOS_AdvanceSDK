//
//  AdvXXCustomRenderFeedAdDataSource.h
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/18.
//  Copyright © 2026. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvRenderFeedAdDataSource.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvXXCustomRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithNativeAdData:(BUMaterialMeta *)data;

@end

NS_ASSUME_NONNULL_END
