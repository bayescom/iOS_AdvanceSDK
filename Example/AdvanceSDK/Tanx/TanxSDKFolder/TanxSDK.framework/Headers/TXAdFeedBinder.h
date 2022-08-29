//
//  TXAdFeedBinder.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/5/11.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <TanxSDK/TXAdFeedModel.h>
#import <TanxSDK/TXAdFeedView.h>

NS_ASSUME_NONNULL_BEGIN

@class TXAdFeedManager;

@interface TXAdFeedBinder : NSObject

@property(nonatomic, weak) TXAdFeedManager * manager;

@property(nonatomic, strong) TXAdFeedModel * model;

@property(nonatomic, strong) TXAdFeedView * feedView;

/// 绑定信息流自渲染view
/// 只传了closeView，而dislikeViews为空的情况下，则点击closeView就是关闭广告。在有dislikeViews的情况下，则选择了具体的关闭理由的视图才是关闭广告
/// @param feedView  必须继承自TXAdFeedView，自渲染的信息流主视图
/// @param closeView 关闭按钮视图，可选。绑定后，点击该视图会触发 TXAdFeedManager 的代理方法  onClickCloseFeed:
/// @param dislikeViews 关闭理由视图数组，可选。第1个视图对应“不感兴趣”选项，第2个视图对应“广告内容质量差”选项。绑定后，点击视图会触发 TXAdFeedManager 的代理方法  didCloseFeed:atIndex:
- (void)bindFeedView:(TXAdFeedView *)feedView closeView:(nullable UIView *)closeView dislikeViews:(nullable NSArray<UIView *> *)dislikeViews;

@end

NS_ASSUME_NONNULL_END
