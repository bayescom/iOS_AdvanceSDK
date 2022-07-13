//
//  TXAdFeedManager.h
//  TanxSDK
//
//  Created by guqiu on 2022/1/4.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TanxSDK/TXAdFeedManagerDelegate.h>
#import <TanxSDK/TXAdFeedTemplateConfig.h>
#import <TanxSDK/TXAdFeedModel.h>
#import <TanxSDK/TXAdFeedView.h>
#import <TanxSDK/TXAdFeedBinder.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TXAdGetFeedAdBlock)(NSArray <TXAdFeedModel *> * _Nullable viewModelArray, NSError * _Nullable error);

@interface TXAdFeedModule : NSObject

/// 模板内容
@property (nonatomic, strong) UIView *view;

/// 模板的size
@property (nonatomic, assign) CGSize size;

/// 当前数据源
@property (nonatomic, strong) TXAdFeedModel *feed;

@end

@interface TXAdFeedManager : NSObject

/// 自定义初始化
/// @param delegate 委托协议对象
/// @param scrollView 滑动容器
- (instancetype)initWithDelegate:(id<TXAdFeedManagerDelegate>)delegate andScrollView:(UIScrollView *)scrollView;

/// 发起获取feed广告请求
/// @param block 返回广告数据（@媒体可获取通过TXAdFeedModel的ecpm获取报价，若为空则表明该媒体没有获取权限）
/// @param pid 广告pid
/// @param postionArray 获取多少个广告（最多不超过三个），放在哪些坑位（比如 [@2，@6，@9]），⚠️⚠️这些坑位下标从0开始⚠️⚠️，⚠️⚠️和第几页无关不需要累加上页大小⚠️⚠️。
- (void)getFeedAdWithBlock:(TXAdGetFeedAdBlock)block
                   withPid:(NSString * __nonnull)pid
               andPosArray:(NSArray <NSNumber *> *)postionArray;

/// 通过广告数据，获取信息流广告模板（返回给媒体的模板是上下左右不留padding的，由媒体自己控制padding）
/// @param modelArray 信息流广告数据数组（必传）
/// @param isJoinBidding 是否参竞
/// @param creativeIdArray 参竞后，成功竞得的creativeId数组
/// @param config 模板的相关UI配置
- (NSArray <TXAdFeedModule *> *)renderFeedTemplateWithModel:(NSArray <TXAdFeedModel *> *__nonnull)modelArray
                                                joinBidding:(BOOL)isJoinBidding
                                             andCreativeIds:(NSArray <NSString *>*__nullable)creativeIdArray
                                          andTemplateConfig:(TXAdFeedTemplateConfig *)config;

/// 通过广告数据，获取自渲染绑定器
/// @param modelArray 信息流广告数据数组（必传）
/// @param isJoinBidding 是否参竞
/// @param creativeIdArray 参竞后，成功竞得的creativeId数组
- (NSArray <TXAdFeedBinder *> *)customRenderingBinderWithModels:(NSArray <TXAdFeedModel *> *__nonnull)modelArray
                                                    joinBidding:(BOOL)isJoinBidding
                                                 andCreativeIds:(NSArray <NSString *>*__nullable)creativeIdArray;


/// 重新设置一遍Feed信息流的UII配置（当发生了字体变化、暗黑模式和正常模式切换的情况）
/// @param config 配置
- (void)resetFeedConfig:(TXAdFeedTemplateConfig *)config;

- (instancetype) init __attribute__((unavailable("init not available,call initWithDelegate andScrollView")));
+ (instancetype) new __attribute__((unavailable("new not available, call initWithDelegate andScrollView")));

@end

NS_ASSUME_NONNULL_END
