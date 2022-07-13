//
//  TXAdRewardVideoAd.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/5/31.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <TanxSDK/TXAdRewardVideoModel.h>
#import <TanxSDK/TXAdShowRewardVideoConfiguration.h>
#import <TanxSDK/TXAdRewardVideoRewardInfo.h>
#import <TanxSDK/TXAdRewardVideoAdConfiguration.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^TXAdGetRewardVideoAdBlock)(TXAdRewardVideoModel * _Nullable model, NSError * _Nullable error);
typedef void(^TXAdPreloadRewardVideoAdCompletion)(NSError * _Nullable error);

@class TXAdRewardVideoAd;

@protocol TXAdRewardVideoAdDelegate <NSObject>
@optional

/// 广告load成功回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidLoad:(TXAdRewardVideoAd *)rewardVideoAd;

/// 广告load失败回调
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didLoadFailWithError:(NSError *)error;

/// 视频下载成功回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidDownloadVideo:(TXAdRewardVideoAd *)rewardVideoAd;

/// 视频下载失败回调，下载失败后会进行重试，该回调可能会被多次调用
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didDownloadFailWithError:(NSError *)error;

/// 广告弹出成功回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidShow:(TXAdRewardVideoAd *)rewardVideoAd;

/// 广告弹出出错回调
/// @param rewardVideoAd 广告管理对象
/// @param error 错误
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didShowFailWithError:(NSError *)error;

/// 广告跳过回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidSkip:(TXAdRewardVideoAd *)rewardVideoAd;

/// 广告关闭回调
/// @param rewardVideoAd 广告管理对象
- (void)rewardVideoAdDidClose:(TXAdRewardVideoAd *)rewardVideoAd;

/// 激励视频播放完成或者出错
/// @param rewardVideoAd 广告管理对象
/// @param error nil 时代表成功
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didFinishPlayingWithError:(nullable NSError *)error;

/// 发奖回调
/// @param rewardVideoAd 广告管理对象
/// @param rewardInfo 发奖信息
- (void)rewardVideoAd:(TXAdRewardVideoAd *)rewardVideoAd didReceiveRewardInfo:(TXAdRewardVideoRewardInfo *)rewardInfo;
@end



/// 激励视频广告管理对象
@interface TXAdRewardVideoAd : NSObject

/// 回调代理
@property(nonatomic, weak) id<TXAdRewardVideoAdDelegate> delegate;

/// 配置
@property(nonatomic, strong, readonly) TXAdRewardVideoAdConfiguration * configuration;

/// 广告pid
@property(nonatomic, copy, readonly) NSString * pid;

/// loadAd调用后，请求到的广告model
@property(nonatomic, strong, readonly, nullable) TXAdRewardVideoModel * model;

/// 初始化方法
/// @param pid 广告pid
- (instancetype)initWithPid:(NSString *)pid NS_DESIGNATED_INITIALIZER;

/// 加载广告，超时时间可在configuration中配置
- (void)loadAd;

/// 上报竞价结果
/// @param isWin 是否赢得竞价
- (void)uploadBiddingResult:(BOOL)isWin;

/// 展示激励视频，在 rewardVideoAdDidLoad: 或者 rewardVideoAdDidDownloadVideo: 回调过后调用
/// @param viewController 当前所在VC
- (void)showAdFromRootViewController:(UIViewController *)viewController;

/// 展示激励视频，在 rewardVideoAdDidLoad: 或者 rewardVideoAdDidDownloadVideo: 回调过后调用
/// @param viewController 当前所在VC
/// @param configuration 配置，可设置是否默认静音
- (void)showAdFromRootViewController:(UIViewController *)viewController
                       configuration:(nullable TXAdShowRewardVideoConfiguration *)configuration;

- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
