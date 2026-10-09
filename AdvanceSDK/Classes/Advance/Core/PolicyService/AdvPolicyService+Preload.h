//
//  AdvPolicyService+Preload.h
//  AdvanceSDK
//

#import "AdvPolicyService.h"

NS_ASSUME_NONNULL_BEGIN

/// 自动预加载策略成功后的独立结束回调，不复用策略请求失败回调。
@protocol AdvPolicyServicePreloadDelegate <AdvPolicyServiceDelegate>

@optional
- (void)policyServicePreloadDidFailWithError:(NSError *)error;

@end

/// 供自动预加载协调器调用的内部接口。
@interface AdvPolicyService (Preload)

- (void)adv_loadPolicyDataWithAdspotId:(NSString *)adspotId
                                 reqId:(NSString *)reqId
                                 extra:(nullable NSDictionary *)extra
                  preloadSupplierSDKID:(NSString *)supplierSDKID;

- (BOOL)adv_finishPreloadForSupplier:(AdvSupplier *)supplier
                               price:(NSInteger)price
                               error:(nullable NSError *)error;

- (void)adv_cancelPreloadForSupplier:(AdvSupplier *)supplier;

@end

NS_ASSUME_NONNULL_END
