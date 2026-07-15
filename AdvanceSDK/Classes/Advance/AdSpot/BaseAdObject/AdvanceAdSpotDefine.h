#import <UIKit/UIKit.h>
#import "AdvanceAdInfo.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceAdSpotDefine <NSObject>
/// 聚合广告位Id
@property (nonatomic, copy) NSString *adspotid;

/// 广告请求id
@property (nonatomic, copy) NSString *reqId;

/// 自定义扩展参数
@property (nonatomic, strong) NSMutableDictionary *extraDict;

/// 并行渠道adpater存储器
@property (nonatomic, strong) NSMutableDictionary * _Nullable adapterMap;

/// 被命中展示的Adapter
@property (nonatomic, strong) id targetAdapter;

/// 策略管理对象
@property (nonatomic, strong) id _Nullable manager;

/// 渠道对象列表
@property (nonatomic, strong) NSMutableArray *suppliers;

/// 初始化广告位
/// @param adspotid 广告位id
/// @param extra 自定义扩展参数
- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(nullable NSDictionary *)extra;
                       

/// 加载广告策略
- (void)loadAdPolicy;

/// 获取胜出的渠道广告信息
- (AdvanceAdInfo * _Nullable)getAdInfo;

/// 销毁对象
- (void)destroyAdapters;

@end

NS_ASSUME_NONNULL_END

