//
//  AdvPolicyService+Preload.m
//  AdvanceSDK
//

#import <objc/runtime.h>
#import "AdvApiService.h"
#import "AdvAdCacheManager.h"
#import "AdvConfigCacheManager.h"
#import "AdvError.h"
#import "AdvFrequencyControlManager.h"
#import "AdvParameterHandler.h"
#import "AdvPolicyService+Preload.h"
#import "AdvSupplierLoader.h"
#import "NSArray+Adv.h"
#import "NSObject+AdvModel.h"

@interface AdvPolicyServicePreloadContext : NSObject
@property (nonatomic, copy) NSString *supplierSDKID;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) NSTimeInterval loadTimestamp;
@property (nonatomic, assign, getter=isFinished) BOOL finished;
@end

@implementation AdvPolicyServicePreloadContext
@end

@interface AdvPolicyService ()
@property (nonatomic, strong, nullable) AdvPolicyServicePreloadContext *preloadContext;
@end

@implementation AdvPolicyService (Preload)

static void *AdvPolicyServicePreloadContextKey = &AdvPolicyServicePreloadContextKey;

- (AdvPolicyServicePreloadContext *)preloadContext {
    return objc_getAssociatedObject(self, AdvPolicyServicePreloadContextKey);
}

- (void)setPreloadContext:(AdvPolicyServicePreloadContext *)preloadContext {
    objc_setAssociatedObject(self, AdvPolicyServicePreloadContextKey, preloadContext, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)adv_loadPolicyDataWithAdspotId:(NSString *)adspotId
                                 reqId:(NSString *)reqId
                                 extra:(nullable NSDictionary *)extra
                  preloadSupplierSDKID:(NSString *)supplierSDKID {
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self adv_loadPolicyDataWithAdspotId:adspotId
                                           reqId:reqId
                                           extra:extra
                            preloadSupplierSDKID:supplierSDKID];
        });
        return;
    }
    
    AdvPolicyServicePreloadContext *context = [[AdvPolicyServicePreloadContext alloc] init];
    context.supplierSDKID = [supplierSDKID copy];
    context.loadTimestamp = [[NSDate date] timeIntervalSince1970] * 1000;
    self.preloadContext = context;
    
    NSError *frequencyError = [[AdvFrequencyControlManager sharedInstance] consumePreloadRequestCountForAdspotId:adspotId];
    if (frequencyError) {
        self.preloadContext = nil;
        if ([self.delegate respondsToSelector:@selector(policyServiceLoadFailedWithError:)]) {
            [self.delegate policyServiceLoadFailedWithError:frequencyError];
        }
        return;
    }
    
    NSDictionary *parameters = [AdvParameterHandler requestParameterWithSpotId:adspotId
                                                                         reqId:reqId
                                                                         extra:extra ?: @{}];
    AdvPolicyModel *cachedModel = [[AdvConfigCacheManager sharedInstance] policyModelForAdspotId:adspotId];
    BOOL usesCachedPolicy = cachedModel != nil;
    if (cachedModel) {
        [self preloadStartWithModel:cachedModel context:context];
    }
    
    // 与普通策略服务保持一致：命中缓存策略时立即使用，同时请求最新策略，仅更新后续请求使用的策略缓存。
    // 如果当前缓存策略中没有目标渠道，则跳过本次预加载，不等待刷新结果重试。
    [AdvApiService loadPolicyDataWithParameters:parameters completion:^(AdvPolicyModel *model, NSError *error) {
        if (error) {
            if (!usesCachedPolicy && self.preloadContext == context) {
                self.preloadContext = nil;
                if ([self.delegate respondsToSelector:@selector(policyServiceLoadFailedWithError:)]) {
                    [self.delegate policyServiceLoadFailedWithError:error];
                }
            }
            return;
        }
        
        if (model.setting.enable_strategy_cache == 1) {
            [[AdvConfigCacheManager sharedInstance] cachePolicyModel:model forAdspotId:adspotId];
        }
        if (!usesCachedPolicy && self.preloadContext == context) {
            [self preloadStartWithModel:model context:context];
        }
    }];
}

- (void)preloadStartWithModel:(AdvPolicyModel *)model context:(AdvPolicyServicePreloadContext *)context {
    if (context.isFinished || self.preloadContext != context) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(policyServiceLoadSuccessWithModel:)]) {
        [self.delegate policyServiceLoadSuccessWithModel:model];
    }
    
    id<AdvPolicyServicePreloadDelegate> delegate = (id<AdvPolicyServicePreloadDelegate>)self.delegate;
    AdvSupplier *preloadSupplier = [model.suppliers adv_filter:^BOOL(AdvSupplier *supplier) {
        return [supplier.sdk_id isEqualToString:context.supplierSDKID] && supplier.enable_cache;
    }].firstObject;
    if (!preloadSupplier) {
        context.finished = YES;
        self.preloadContext = nil;
        if ([delegate respondsToSelector:@selector(policyServicePreloadDidFailWithError:)]) {
            NSError *error = [AdvError errorWithCode:AdvErrorCode_NoneSupplier
                                             message:@"预加载策略中未找到已曝光且允许缓存的广告源"].toNSError;
            [delegate policyServicePreloadDidFailWithError:error];
        }
        return;
    }
    context.supplier = preloadSupplier;
    
    [AdvApiService reportAdDataWithEventType:AdvSupplierReportTKEventLoaded
                                    supplier:preloadSupplier
                               loadTimestamp:context.loadTimestamp
                                       error:nil];
    
    [self performSelector:@selector(preloadObserveTimeout) withObject:nil afterDelay:model.setting.parallel_timeout * 1.0 / 1000];
    
    [AdvSupplierLoader loadSupplier:preloadSupplier completion:^(NSError *error) {
        AdvPolicyServicePreloadContext *currentContext = self.preloadContext;
        if (currentContext != context || context.isFinished || preloadSupplier.loadAdState != AdvSupplierLoadAdReady) {
            return;
        }
        if (error) {
            [self adv_finishPreloadForSupplier:preloadSupplier price:0 error:error];
            if ([delegate respondsToSelector:@selector(policyServicePreloadDidFailWithError:)]) {
                [delegate policyServicePreloadDidFailWithError:error];
            }
            return;
        }
        
        [AdvApiService reportAdDataWithEventType:AdvSupplierReportTKEventLoadEnd
                                        supplier:preloadSupplier
                                   loadTimestamp:context.loadTimestamp
                                           error:nil];

        AdvAdCacheModel *cachedAdModel = preloadSupplier.enable_cache
            ? [[AdvAdCacheManager sharedInstance] adCacheModelFromCachedKey:preloadSupplier.sdk_id]
            : nil;
        NSError *frequencyError = [[AdvFrequencyControlManager sharedInstance]
                                   consumePreloadRequestCountForSupplier:preloadSupplier
                                   usingCachedAd:(cachedAdModel != nil)];
        if (frequencyError) {
            [self adv_finishPreloadForSupplier:preloadSupplier price:0 error:frequencyError];
            if ([delegate respondsToSelector:@selector(policyServicePreloadDidFailWithError:)]) {
                [delegate policyServicePreloadDidFailWithError:frequencyError];
            }
            return;
        }

        if ([self.delegate respondsToSelector:@selector(policyServiceLoadAnySupplier:cachedAdModel:)]) {
            [self.delegate policyServiceLoadAnySupplier:preloadSupplier cachedAdModel:cachedAdModel];
        }
    }];
}

/// 根据渠道广告加载结果更新状态并上报
- (BOOL)adv_finishPreloadForSupplier:(AdvSupplier *)supplier price:(NSInteger)price error:(nullable NSError *)error {
    AdvPolicyServicePreloadContext *context = self.preloadContext;
    if (!context || context.isFinished || supplier != context.supplier ||
        supplier.loadAdState != AdvSupplierLoadAdReady) {
        return NO;
    }
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadObserveTimeout) object:nil];
    context.finished = YES;
    if (error) {
        supplier.loadAdState = error.code == AdvErrorCode_SupplierTimeout
        ? AdvSupplierLoadAdTimeout : AdvSupplierLoadAdFailed;
        [AdvApiService reportAdDataWithEventType:AdvSupplierReportTKEventFailed
                                        supplier:supplier
                                   loadTimestamp:context.loadTimestamp
                                           error:error];
        return YES;
    }
    
    [self setECPMIfNeeded:price supplier:supplier];
    supplier.loadAdState = AdvSupplierLoadAdSuccess;
    [AdvApiService reportAdDataWithEventType:AdvSupplierReportTKEventSucceed
                                    supplier:supplier
                               loadTimestamp:context.loadTimestamp
                                       error:nil];
    return YES;
}

/// 取消当前预加载渠道并清理超时任务
- (void)adv_cancelPreloadForSupplier:(AdvSupplier *)supplier {
    AdvPolicyServicePreloadContext *context = self.preloadContext;
    if (!context || context.isFinished || supplier != context.supplier ||
        supplier.loadAdState != AdvSupplierLoadAdReady) {
        return;
    }
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(preloadObserveTimeout) object:nil];
    context.finished = YES;
    supplier.loadAdState = AdvSupplierLoadAdFailed;
}

// 超时监测
- (void)preloadObserveTimeout {
    AdvPolicyServicePreloadContext *context = self.preloadContext;
    if (!context || context.isFinished || !context.supplier ||
        context.supplier.loadAdState != AdvSupplierLoadAdReady) {
        return;
    }
    
    NSError *error = [AdvError errorWithCode:AdvErrorCode_SupplierTimeout].toNSError;
    if ([self adv_finishPreloadForSupplier:context.supplier price:0 error:error]) {
        id<AdvPolicyServicePreloadDelegate> delegate = (id<AdvPolicyServicePreloadDelegate>)self.delegate;
        if ([delegate respondsToSelector:@selector(policyServicePreloadDidFailWithError:)]) {
            [delegate policyServicePreloadDidFailWithError:error];
        }
    }
}

@end
