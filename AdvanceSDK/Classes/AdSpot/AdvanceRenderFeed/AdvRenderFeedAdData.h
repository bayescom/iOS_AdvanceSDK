//
//  AdvRenderFeedAdData.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import <Foundation/Foundation.h>

@interface AdvRenderFeedAdData : NSObject

// 广告标题
@property (nonatomic, copy, readonly) NSString *title;

// 广告描述
@property (nonatomic, copy, readonly) NSString *desc;

// 广告图标Url
@property (nonatomic, copy, readonly) NSString *iconUrl;

// 广告图片Url集合（单图、多图）
@property (nonatomic, strong, readonly) NSArray *imageUrlList;

// 多媒体素材宽度（单图、多图、视频）
@property (nonatomic, assign, readonly) NSInteger mediaWidth;

// 多媒体素材高度（单图、多图、视频）
@property (nonatomic, assign, readonly) NSInteger mediaHeight;

// 广告CTA按钮展示文案
@property (nonatomic, copy, readonly) NSString *buttonText;

// 是否为视频广告
@property (nonatomic, assign, readonly) BOOL isVideoAd;

// 视频广告时长（单位：ms）
@property (nonatomic, assign, readonly) NSInteger videoDuration;

// 广告的星级（5星制度）
@property (nonatomic, assign, readonly) NSInteger appRating;

@end

