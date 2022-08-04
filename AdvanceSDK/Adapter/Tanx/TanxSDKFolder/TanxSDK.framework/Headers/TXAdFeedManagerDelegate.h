//
//  TXAdFeedManagerDelegate.h
//  TanxCoreSDK
//
//  Created by guqiu on 2022/1/4.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#ifndef TXAdFeedManagerDelegate_h
#define TXAdFeedManagerDelegate_h

@class TXAdFeedModel;

@protocol TXAdFeedManagerDelegate <NSObject>

@required
/// 跳转到h5，需要接入方实现
- (void)jumpToWebH5:(NSString *)webUrl;

@optional

/// 点击了广告
- (void)onClickingFeed:(TXAdFeedModel *)feedModel;

/// 广告渲染成功
- (void)onRenderSuc:(TXAdFeedModel *)feedModel;

/// 广告展示（曝光）
- (void)onExposingFeed:(TXAdFeedModel *)feedModel;

/// 点击了广告关闭按钮
- (void)onClickCloseFeed:(TXAdFeedModel *)feedModel;

/// 点击了“不喜欢”菜单中的选项
/// @param feedModel  feedModel模型
/// @param index  选项次序索引
- (void)didCloseFeed:(TXAdFeedModel*)feedModel atIndex:(NSInteger)index;

/// 广告加载失败
/// @param feedModel  feedModel模型
/// @param error 错误信息
- (void)onFailureFeed:(TXAdFeedModel *)feedModel andError:(NSError *)error;

@end


#endif /* TXAdFeedManagerDelegate_h */
