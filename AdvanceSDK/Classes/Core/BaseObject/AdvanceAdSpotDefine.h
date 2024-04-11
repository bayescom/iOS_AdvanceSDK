//
//  AdvanceAdapter.h
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/16.
//

#import <Foundation/Foundation.h>
#import "AdvPolicyService.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceAdSpotDefine <NSObject>

/// 聚合媒体Id / appId
@property (nonatomic, copy) NSString *mediaId;

/// 聚合广告位Id
@property (nonatomic, copy) NSString *adspotid;

/// 自定义拓展参数
@property (nonatomic, strong) NSDictionary *ext;

/// 广告加载容器视图
@property (nonatomic, weak) UIViewController *viewController;

/// 并行渠道adpater存储器
@property (nonatomic, strong) NSMutableDictionary *adapterMap;

/// 被命中展示的Adapter
@property (nonatomic, strong) id targetAdapter;

/// 策略管理对象
@property (nonatomic, strong) AdvPolicyService *manager;

/// 是否为GroMore聚合ADN
@property (nonatomic, assign) BOOL isGroMoreADN;

/// 初始化媒体信息
/// @param mediaId mediaId
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
- (instancetype)initWithMediaId:(nullable NSString *)mediaId
                       adspotId:(nullable NSString *)adspotid
                      customExt:(nullable NSDictionary *)ext;

/// 加载广告策略
- (void)loadAdPolicy;

/// gromore bidding时 获取Advance广告位的竞胜渠道
- (void)catchBidTargetWhenGroMoreBiddingWithPolicyModel:(nullable AdvPolicyModel *)model;

@end

NS_ASSUME_NONNULL_END

