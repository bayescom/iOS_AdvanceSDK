//
//  KSEmbedAdConfig.h
//  KSAdSDK
//
//  Created by jie cai on 2020/4/26.
//

#import <Foundation/Foundation.h>

@protocol KSCUEmbedAdDataSource;
@protocol KSCUEmbedAdProtocol;

NS_ASSUME_NONNULL_BEGIN

@interface KSCUEmbedAdConfig : NSObject

@property (nonatomic, assign) BOOL allowInsertThirdAd;

/// 数据源代理
@property (nonatomic, weak) id<KSCUEmbedAdDataSource> dataSource;

@end

@interface KSCUEmbedAdsRequest : NSObject

/// 第 requestCount 次加载请求,  = 1 为下拉刷新或者首次加载, > 1 为加载更多
/*
   warning:
   第 2 次结束后,发起第三次请求 requestCount = 3,若第三次请求失败,下一次请求 从 3 开始,
 */
@property (nonatomic, assign, readonly) NSInteger  requestCount;
/// 当前加载请求预留广告位总数
@property (nonatomic, assign, readonly) NSInteger  lastRequestAdCount;

- (BOOL)isLoadMore;

@end

#pragma mark - 广告配置数据源协议协议 KSCUEmbedAdDataSource

@protocol KSCUEmbedAdDataSource <NSObject>

@required

/// 即将发起请求
- (void)embedAdConfig:(KSCUEmbedAdConfig *)embedAdConfig
      willBeginRuqest:(KSCUEmbedAdsRequest *)requestAds;

/// 请求结束
/*
   建议:每当一次请求结束后,加载当次请求的广告
 */
- (void)embedAdConfig:(KSCUEmbedAdConfig *)embedAdConfig
         didEndRuqest:(KSCUEmbedAdsRequest *)requestAds
                error:(NSError * _Nullable)error;

/// 获取外置广告数据源
- (_Nullable id<KSCUEmbedAdProtocol>)embedAdConfig:(KSCUEmbedAdConfig *)embedAdConfig                                      adAtIndex:(NSInteger)index;

@end

#pragma mark - 配置广告模型协议 KSCUEmbedAdProtocol

@protocol KSCUEmbedAdProtocol <NSObject>

@required
/// 需要内嵌广告视图, 与展示内容大小 一致
- (nonnull UIView *)embedAdView;
/// 完全展示 embedAdView
- (void)embedAdViewDidFullDisplay;
/// 完全消失 embedAdView
- (void)embedAdViewDidEndDisplay;

@optional
/// 展示内容的唯一标识，注意：*****如果不实现这个方法或者返回空，SDK不会回调页面展示状态*****
- (NSString *)embededAdUniqueID;
/// 即将展示预加载 embedAdView
- (void)embedAdViewWillDisplay;
/// 嵌入 ViewController DidAppear 显示
- (void)embedAdInViewControllerDidAppear;
/// 嵌入 ViewController DidDisappear 消失
- (void)embedAdInViewControllerDidDisappear;

@end

NS_ASSUME_NONNULL_END
