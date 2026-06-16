//
//  AdvBaiduRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdDataSource.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>

@interface AdvBaiduRenderFeedAdDataSource : NSObject <AdvRenderFeedAdDataSource>

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject;

@end
