
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class AdvanceAdspotConfig;

#pragma mark: SDK通用配置信息
@interface AdvanceSDKConfig : NSObject <NSCoding>
// 广告位配置映射；key 为广告位 ID，value 为对应广告位的频控配置
@property (nonatomic, strong) NSDictionary<NSString *, AdvanceAdspotConfig *> *adspot_configs;

@end


/// SDK 通用配置中按广告位下发的频控配置
@interface AdvanceAdspotConfig : NSObject <NSCoding>
/// 广告位 ID
@property (nonatomic, copy) NSString *adspot_id;
/// 两次真实广告请求之间的最小时间间隔，单位 ms；0 表示不限制
@property (nonatomic, assign) NSInteger req_interval;
/// 日请求次数上限；0 表示不限制
@property (nonatomic, assign) NSInteger req_limit;
/// 日有效曝光次数上限；0 表示不限制
@property (nonatomic, assign) NSInteger imp_limit;
/// 日点击次数上限；0 表示不限制
@property (nonatomic, assign) NSInteger click_limit;

@end

NS_ASSUME_NONNULL_END
