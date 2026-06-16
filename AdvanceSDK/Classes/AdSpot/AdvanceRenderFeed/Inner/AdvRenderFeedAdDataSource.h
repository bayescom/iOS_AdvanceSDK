//
//  AdvRenderFeedAdDataSource.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/15.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol AdvRenderFeedAdDataSource <NSObject>

@optional
// 广告标题
- (NSString *)title;

// 广告描述
- (NSString *)desc;

// 广告图标Url
- (NSString *)iconUrl;

// 广告图片Url集合（单图、多图）
- (NSArray *)imageUrlList;

// 多媒体素材宽度（单图、多图、视频）
- (NSInteger)mediaWidth;

// 多媒体素材高度（单图、多图、视频）
- (NSInteger)mediaHeight;

// 广告CTA按钮展示文案
- (NSString *)buttonText;

// 是否为视频广告
- (BOOL)isVideoAd;

// 视频广告时长（单位：ms）
- (NSInteger)videoDuration;

// 广告的星级（5星制度）
- (NSInteger)appRating;

@end
