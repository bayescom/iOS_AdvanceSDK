
#import <Foundation/Foundation.h>
NS_ASSUME_NONNULL_BEGIN

@class AdvanceAdspotConfig;
@class AdvMaterialInspectionConfig;

#pragma mark: SDK通用配置信息
@interface AdvanceSDKConfig : NSObject <NSCoding>
// 广告位配置映射；key 为广告位 ID，value 为对应广告位的频控配置
@property (nonatomic, strong) NSDictionary<NSString *, AdvanceAdspotConfig *> *adspot_configs;
/// 素材巡检配置；服务端未下发时保持关闭。
@property (nonatomic, strong, nullable) AdvMaterialInspectionConfig *material_inspection_config;

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

/// SDK 通用配置中的素材巡检参数
@interface AdvMaterialInspectionConfig : NSObject <NSCoding>
/// 是否启用，默认 0
@property (nonatomic, assign) NSInteger enable;
/// 曝光采样比例，范围 [0, 1]，默认 0.01
@property (nonatomic, assign) double exposure_sample_rate;
/// 曝光后首次采样延迟，单位 ms，默认 1000
@property (nonatomic, assign) NSInteger capture_delay_ms;
/// 单张上传图片的大小上限，单位 KB，默认 500
@property (nonatomic, assign) NSInteger image_max_size;

@end

NS_ASSUME_NONNULL_END
