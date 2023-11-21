//
//  AdvRenderFeedAdElement.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import <Foundation/Foundation.h>

@interface AdvRenderFeedAdElement : NSObject

// 广告标题
@property (nonatomic, copy) NSString *title;

// 广告描述
@property (nonatomic, copy) NSString *desc;

// 广告图标Url
@property (nonatomic, copy) NSString *iconUrl;

// 广告图片Url集合（单图、多图）
@property (nonatomic, strong) NSArray *imageUrlList;

// 多媒体素材宽度（单图、多图、视频）
@property (nonatomic, assign) NSInteger mediaWidth;

// 多媒体素材高度（单图、多图、视频）
@property (nonatomic, assign) NSInteger mediaHeight;

// 广告CTA按钮展示文案
@property (nonatomic, copy) NSString *buttonText;

// 是否为视频广告
@property (nonatomic, assign) BOOL isVideoAd;

// 视频广告时长（单位：ms）
@property (nonatomic, assign) NSInteger videoDuration;

// 广告的星级（5星制度）
@property (nonatomic, assign) NSInteger appRating;


@end

