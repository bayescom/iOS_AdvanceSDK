//
//  MercuryRewardVideoAd.h
//  Example
//
//  Created by CherryKing on 2019/11/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MercuryRewardVideoAdDelegate <NSObject>

@optional
/// 广告数据加载成功回调
- (void)mercury_rewardVideoAdDidLoad;

/// 广告加载失败回调
- (void)mercury_rewardAdFailError:(nullable NSError *)error;

/// 视频数据下载成功回调，已经下载过的视频会直接回调
- (void)mercury_rewardVideoAdVideoDidLoad;

/// 视频播放页即将曝光回调
- (void)mercury_rewardVideoAdWillVisible;

/// 视频广告曝光回调
- (void)mercury_rewardVideoAdDidExposed;

/// 视频播放页关闭回调
- (void)mercury_rewardVideoAdDidClose;

/// 视频广告信息点击回调
- (void)mercury_rewardVideoAdDidClicked;

/// 视频广告播放达到激励条件回调
- (void)mercury_rewardVideoAdDidRewardEffective;

/// 视频广告视频播放完成
- (void)mercury_rewardVideoAdDidPlayFinish;

@end

@interface MercuryRewardVideoAd : NSObject
@property (nonatomic, weak) id<MercuryRewardVideoAdDelegate> delegate;

/// 插屏广告是否加载完成
@property (nonatomic, assign, readonly) BOOL isAdValid;

/// 初始化激励广告
/// @param adspotId 广告Id
/// @param delegate 代理对象
- (instancetype)initAdWithAdspotId:(NSString * _Nonnull)adspotId
                          delegate:(id<MercuryRewardVideoAdDelegate> _Nullable)delegate;

/// 加载广告
- (void)loadRewardVideoAd;

/// 弹出激励广告
- (void)showAdFromVC:(UIViewController *)vc;
@end

NS_ASSUME_NONNULL_END
