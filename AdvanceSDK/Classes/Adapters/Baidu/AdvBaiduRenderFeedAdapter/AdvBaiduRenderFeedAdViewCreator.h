//
//  AdvBaiduRenderFeedAdViewCreator.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/12.
//

#import <Foundation/Foundation.h>
#import "AdvRenderFeedAdViewCreator.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvBaiduRenderFeedAdViewCreator : NSObject <AdvRenderFeedAdViewCreator>

- (instancetype)initWithDataObject:(BaiduMobAdNativeAdObject *)dataObject
                            adView:(BaiduMobAdNativeAdView *)adView
                         videoView:(BaiduMobAdNativeVideoView *)videoView;

@end

NS_ASSUME_NONNULL_END
