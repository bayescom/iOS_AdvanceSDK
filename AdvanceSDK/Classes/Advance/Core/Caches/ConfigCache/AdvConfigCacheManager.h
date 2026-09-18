
#import <Foundation/Foundation.h>
#import "AdvanceSDKConfig.h"
#import "AdvPolicyModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvConfigCacheManager : NSObject

+ (instancetype)sharedInstance;

// 缓存SDK通用配置信息
- (void)cacheSDKConfig:(AdvanceSDKConfig *)config;

// 获取缓存配置信息
- (AdvanceSDKConfig *)sdkConfig;

/// 按当前 App ID 和广告位将策略模型同步归档到磁盘，记录写入时间。
- (void)cachePolicyModel:(AdvPolicyModel *)model forAdspotId:(NSString *)adspotId;

/// 从磁盘反序列化得到独立的策略模型，过期时清理并返回 nil；读取不会续期。
- (nullable AdvPolicyModel *)policyModelForAdspotId:(NSString *)adspotId;

@end

NS_ASSUME_NONNULL_END
