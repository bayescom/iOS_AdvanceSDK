//
//  AdvSupplierLoader.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import "AdvSupplierLoader.h"
#import "AdvConstantHeader.h"
#import "AdvError.h"
#import "AdvCustomAdnCacheManager.h"
#import "objc/message.h"

@interface AdvSupplierLoader ()

@property (nonatomic, strong, class) NSMutableDictionary *initializedDict;

@end

static NSMutableDictionary *_initializedDict = nil;

@implementation AdvSupplierLoader

+ (NSMutableDictionary *)initializedDict {
    if (!_initializedDict) {
        _initializedDict = [NSMutableDictionary dictionary];
    }
    return _initializedDict;
}

+ (void)setInitializedDict:(NSMutableDictionary *)initializedDict {
    _initializedDict = initializedDict;
}

// 加载渠道SDK进行初始化调用
+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(NSError *error))completion {
    
    NSString *adapterName = [self mappingConfigAdapterNameWithSupplierId:supplier.identifier];
    /// 媒体未引入渠道SDK或Adapter
    if (!NSClassFromString(adapterName)) {
        NSError *error = [AdvError errorWithCode:AdvErrorCode_SupplierUninstalled].toNSError;
        if (supplier.is_custom_adn) {
            error = [AdvError errorWithCode:AdvErrorCode_CustomAdnLoadFailed].toNSError;
        }
        dispatch_async(dispatch_get_main_queue(), ^{ // 将当前调用延迟到下一个 RunLoop 周期执行。
            completion(error);
        });
        return;
    }
    /// 已经初始化过的渠道 直接返回成功
    if ([[AdvSupplierLoader.initializedDict objectForKey:supplier.identifier] boolValue]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(nil);
        });
        return;
    }
    
    Class protocolClass = NSClassFromString(adapterName);
    SEL initSelector = NSSelectorFromString(@"initializeAdapterWithAppId:appKey:completion:");
    if ([protocolClass respondsToSelector:initSelector]) {
        // 定义block
        void (^completionHandler)(NSError *error) = ^void (NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
                completion(wrappedError);
            });
        };
        ((void (*)(id, SEL, id, id, id))objc_msgSend)(protocolClass, initSelector, supplier.mediaid, supplier.mediakey, completionHandler);
    } else { // 只有自定义ADN才会进入
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([AdvError errorWithCode:-100 message:@"自定义ADN未遵循初始化协议"].toNSError);
        });
    }
}

/// 标记渠道已经被初始化
+ (NSError *)markSupplierInitialized:(AdvSupplier *)supplier error:(NSError *)error {
    if (!error) {
        [AdvSupplierLoader.initializedDict setObject:@YES forKey:supplier.identifier];
        return nil;
    }
    /// 包装成更容易识别的错误信息
    NSError *wrappedError = [AdvError errorWithCode:AdvErrorCode_SupplierInitFailed message:error.userInfo[NSLocalizedDescriptionKey]].toNSError;
    return wrappedError;
}

+ (NSString *)mappingConfigAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"AdvSigmobConfigAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkConfigAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customConfigAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingSplashAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercurySplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"AdvSigmobSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkSplashAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customSplashAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingInterstitialAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"AdvSigmobInterstitialAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkInterstitialAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customInterstitialAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingRewardAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"AdvSigmobRewardVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkRewardVideoAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customRewardVideoAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingFullScreenAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJFullScreenVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTFullScreenVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSFullScreenVideoAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduFullScreenVideoAdapter";
    }
    return clsName;
}

+ (NSString *)mappingNativeExpressAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxNativeExpressAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkNativeExpressAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customNativeExpressAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingRenderFeedAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"AdvKSRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"AdvBaiduRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"AdvTanxRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"AdvSigmobRenderFeedAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkRenderFeedAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customRenderFeedAdapterClassName;
    }
    return clsName;
}

+ (NSString *)mappingBannerAdapterNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"AdvCSJBannerAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"AdvGDTBannerAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"AdvMercuryBannerAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
        clsName = @"AdvFunlinkBannerAdapter";
    } else { // 自定义ADN
        clsName = [AdvSupplierLoader getCustomAdnWithSupplierId:supplierId].customBannerAdapterClassName;
    }
    return clsName;
}

// 根据id获取自定义ADN对象
+ (AdvCustomAdnModel *)getCustomAdnWithSupplierId:(NSString *)supplierId {
    // 从缓存中获取adnlist信息
    AdvCustomAdnListInfo *cacheInfo = [[AdvCustomAdnCacheManager sharedInstance] customAdnlistInfo];
    if (cacheInfo.custom_adn_list.count) {
        AdvCustomAdnModel *adn = [cacheInfo.custom_adn_list adv_filter:^BOOL(AdvCustomAdnModel *model) {
            return [model.adnId isEqualToString:supplierId];
        }].firstObject;
        return adn;
    }
    return nil;
}

@end
