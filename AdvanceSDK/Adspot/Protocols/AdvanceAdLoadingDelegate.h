//
//  AdvanceAdLoadingDelegate.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#ifndef AdvanceAdLoadingDelegate_h
#define AdvanceAdLoadingDelegate_h

@protocol AdvanceAdLoadingDelegate <NSObject>

@optional
/// 广告策略服务加载成功
- (void)didFinishLoadingADPolicyWithSpotId:(NSString *)spotId;

/// 广告策略服务加载失败
/// @param spotId 广告位id
/// @param error 聚合SDK的错误信息
/// @param description 每个渠道的错误描述，部分情况下为nil； key的命名规则: 渠道名-优先级
- (void)didFailLoadingADPolicyWithSpotId:(NSString *)spotId
                                 error:(NSError *)error
                           description:(NSDictionary *)description;

/// Ad start loading
/// @param spotId 广告位id
/// @param sourceId 广告源（渠道）id
- (void)didStartLoadingADSourceWithSpotId:(NSString *)spotId
                                 sourceId:(NSString *)sourceId;

/// Ad start bidding
- (void)didStartBiddingADWithSpotId:(NSString *)spotId;
                              
/// Ad bidding success
- (void)didFinishBiddingADWithSpotId:(NSString *)spotId
                               price:(NSInteger)price;
/// Ad bidding fail
- (void)didFailBiddingADWithSpotId:(NSString *)spotId
                             error:(NSError *)error;


/// 广告曝光成功
- (void)advanceExposured;

/// 广告点击回调
- (void)advanceClicked;

/// 广告数据请求成功后调用
- (void)advanceUnifiedViewDidLoad;

/// 广告关闭的回调
- (void)advanceDidClose;

@end

#endif
