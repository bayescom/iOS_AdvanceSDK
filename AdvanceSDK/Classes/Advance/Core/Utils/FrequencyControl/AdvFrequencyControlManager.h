//
//  AdvFrequencyControlManager.h
//  AdvanceSDK
//

#import <Foundation/Foundation.h>

@class AdvSupplier;

NS_ASSUME_NONNULL_BEGIN

/// 负责广告位请求、曝光和点击的本地频控规则与状态管理。
@interface AdvFrequencyControlManager : NSObject

+ (instancetype)sharedInstance;

#pragma mark: - 广告位级频控
/// 原子校验曝光、点击、请求次数和请求间隔，通过后提交请求计数和请求时间。
/// 调用方应在开始一次聚合策略加载前调用；缓存策略与实时更新合计一次，失败、超时也计一次。
/// 未下发该广告位配置时不拦截，但仍记录请求，以便配置稍后生效时保持当日口径完整。
/// 返回 nil 表示通过且请求名额已消费；返回错误表示拒绝且未消费请求名额。
- (nullable NSError *)consumeRequestQuotaForAdspotId:(NSString *)adspotId;

/// 仅校验并消费广告位每日请求次数，不检查请求间隔、曝光或点击频控，也不更新时间间隔用的最近请求时间。
/// 未下发该广告位配置时不拦截，但仍记录请求次数。
/// 返回 nil 表示通过且请求次数已消费；返回错误表示请求次数已达上限且未消费。
- (nullable NSError *)consumePreloadRequestCountForAdspotId:(NSString *)adspotId;

/// 校验广告是否允许展示，只检查曝光和点击次数，不预占展示名额。
/// 返回 nil 表示允许展示；返回错误表示曝光或点击已达到上限。
- (nullable NSError *)canDisplayAdForAdspotId:(NSString *)adspotId;

/// 提交一次有效曝光计数；调用方负责确保同一次曝光只提交一次。
- (void)recordValidImpressionForAdspotId:(NSString *)adspotId;

/// 提交一次点击计数；调用方负责确保同一次点击只提交一次。
- (void)recordClickForAdspotId:(NSString *)adspotId;

#pragma mark: - 渠道级频控
/// 按渠道 sdk_id 原子检查设备级频控；命中广告缓存时不消费渠道请求次数或间隔。
/// 无 request_limit 时仍记录实际请求，以便后续下发限制时保留当天计数。
- (nullable NSError *)consumeRequestQuotaForSupplier:(AdvSupplier *)supplier
                                       usingCachedAd:(BOOL)usingCachedAd;

/// 预加载渠道时只检查并消费设备每日请求次数，不检查曝光、点击或请求间隔；命中缓存时不消费。
- (nullable NSError *)consumePreloadRequestCountForSupplier:(AdvSupplier *)supplier
                                              usingCachedAd:(BOOL)usingCachedAd;

/// 检查该渠道广告是否允许展示。
- (nullable NSError *)canDisplayAdForSupplier:(AdvSupplier *)supplier;

/// 提交一次该渠道的有效曝光或点击计数；调用方负责同一广告对象内去重。
- (void)recordValidImpressionForSupplier:(AdvSupplier *)supplier;
- (void)recordClickForSupplier:(AdvSupplier *)supplier;

@end

NS_ASSUME_NONNULL_END
