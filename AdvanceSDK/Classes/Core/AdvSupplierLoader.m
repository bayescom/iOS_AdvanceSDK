//
//  AdvSupplierLoader.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import "AdvSupplierLoader.h"
#import "AdvConstantHeader.h"
#import "AdvError.h"
#import "AdvanceCommonConfigAdapter.h"

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
    /// 媒体未引入渠道SDK或Adapter
    if (![self isSDKInstalledWithSupplierId:supplier.identifier]) {
        dispatch_async(dispatch_get_main_queue(), ^{ // 将当前调用延迟到下一个 RunLoop 周期执行。
            completion([AdvError errorWithCode:AdvErrorCode_SupplierUninstalled].toNSError);
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
    
    NSString *clsName = [self mappingConfigAdapterNameWithSupplierId:supplier.identifier];
    Class<AdvanceCommonConfigAdapter> protocolClass = NSClassFromString(clsName);
    if ([protocolClass respondsToSelector:@selector(initializeAdapterWithAppId:appKey:completion:)]) {
        [protocolClass initializeAdapterWithAppId:supplier.mediaid
                                           appKey:supplier.mediakey
                                       completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
                completion(wrappedError);
            });
        }];
    } else { // 只有自定义ADN才会进入
        dispatch_async(dispatch_get_main_queue(), ^{
            completion([AdvError errorWithCode:-100 message:@"自定义ADN未遵循初始化协议"].toNSError);
        });
    }
    
//    if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {// 穿山甲SDK
//        
//        
//        
//    } else if ([supplier.identifier isEqualToString:SDK_ID_GDT] || [supplier.identifier isEqualToString:SDK_ID_KS]) {// 广点通SDK
//        if ([clazz conformsToProtocol:@protocol(AdvanceCommonConfigAdapter)]) {
//            Class<AdvanceCommonConfigAdapter> protocolClass = clazz;
//            if ([protocolClass respondsToSelector:@selector(initializeAdapterWithAppId:appKey:completion:)]) {
//                [protocolClass initializeAdapterWithAppId:supplier.mediaid
//                                                   appKey:supplier.mediakey
//                                               completion:^(NSError *error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                        completion(wrappedError);
//                    });
//                }];
//            }
//        }
//        
//    }  else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {// 百度SDK
//        if ([clazz conformsToProtocol:@protocol(AdvanceCommonConfigAdapter)]) {
//            Class<AdvanceCommonConfigAdapter> protocolClass = clazz;
//            if ([protocolClass respondsToSelector:@selector(initializeAdapterWithAppId:appKey:completion:)]) {
//                [protocolClass initializeAdapterWithAppId:supplier.mediaid
//                                                   appKey:supplier.mediakey
//                                               completion:^(NSError *error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                        completion(wrappedError);
//                    });
//                }];
//            }
//        }
//        
//    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {// 倍业SDK
//        /// 4.4.0（包含）版本之后初始化方式
//        SEL initSelector = NSSelectorFromString(@"initWithAppId:appKey:");
//        if ([clazz respondsToSelector:initSelector]) {
//            ((void (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz, initSelector, supplier.mediaid, supplier.mediakey);
//        }
//        // 定义block
//        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                completion(wrappedError);
//            });
//        };
//        SEL newSelector = NSSelectorFromString(@"startWithCompletionHandler:");
//        if ([clazz respondsToSelector:newSelector]) {
//            ((void (*)(id, SEL, id))objc_msgSend)(clazz, newSelector, completionHandler);
//        }
//        
//    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]) {// Tanx SDK
//        
//        SEL selector = NSSelectorFromString(@"setupSDKWithAppID:andAppKey:");
//        if ([clazz respondsToSelector:selector]) {
//            BOOL res = ((BOOL (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz, selector, supplier.mediaid, supplier.mediakey);
//            NSError *error = res? nil : [AdvError errorWithCode:AdvErrorCode_SupplierInitFailed].toNSError;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                completion(wrappedError);
//            });
//        }
//        
//    } else if ([supplier.identifier isEqualToString:SDK_ID_Sigmob]) {// Sigmob SDK
//        
//        id option = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"WindAdOptions"), NSSelectorFromString(@"alloc"));
//        SEL selector = NSSelectorFromString(@"initWithAppId:appKey:");
//        if ([option respondsToSelector:selector]) {
//            id optionInstance =  ((id (*)(id, SEL, NSString *, NSString *))objc_msgSend)(option, selector, supplier.mediaid, supplier.mediakey);
//            SEL startSelector = NSSelectorFromString(@"startWithOptions:");
//            if ([clazz respondsToSelector:startSelector]) {
//                ((void (*)(id, SEL, id))objc_msgSend)(clazz, startSelector, optionInstance);
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [self markSupplierInitialized:supplier error:nil];
//                    completion(nil);
//                });
//            }
//        }
//        
//    } else if ([supplier.identifier isEqualToString:SDK_ID_Funlink]) {// Funlink SDK
//        
//        if ([clazz conformsToProtocol:@protocol(AdvanceCommonConfigAdapter)]) {
//            Class<AdvanceCommonConfigAdapter> protocolClass = clazz;
//            if ([protocolClass respondsToSelector:@selector(initializeAdapterWithAppId:appKey:completion:)]) {
//                [protocolClass initializeAdapterWithAppId:supplier.mediaid
//                                                   appKey:supplier.mediakey
//                                               completion:^(NSError *error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                        completion(wrappedError);
//                    });
//                }];
//            }
//        }
//        
//    } else if (supplier.isCustom) { // 自定义ADN渠道
////        //从缓存中获取Adn初始化类，执行特定初始化操作
////        NSString *className = @"TBMercuryConfigAdapter";
////        Class clazz = NSClassFromString(className);
//        if ([clazz conformsToProtocol:@protocol(AdvanceCommonConfigAdapter)]) {
//            Class<AdvanceCommonConfigAdapter> protocolClass = clazz;
//            if ([protocolClass respondsToSelector:@selector(initializeAdapterWithAppId:appKey:completion:)]) {
//                [protocolClass initializeAdapterWithAppId:supplier.mediaid
//                                                   appKey:supplier.mediakey
//                                               completion:^(NSError *error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSError *wrappedError = [self markSupplierInitialized:supplier error:error];
//                        completion(wrappedError);
//                    });
//                }];
//            }
//        }
//    }
    
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
    }
    return clsName;
}

//+ (NSString *)mappingSDKClassNameWithSupplierId:(NSString *)supplierId {
//    NSString *clsName = @"";
//    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
//        clsName = @"BUAdSDKManager";
//    } if ([supplierId isEqualToString:SDK_ID_GDT]) {
//        clsName = @"GDTSDKConfig";
//    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
//        clsName = @"KSAdSDKManager";
//    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]){
//        clsName = @"BaiduMobAdManager";
//    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
//        clsName = @"MercuryConfigManager";
//    } else if ([supplierId isEqualToString:SDK_ID_TANX]){
//        clsName = @"TXAdSDKInitializtion";
//    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]){
//        clsName = @"WindAds";
//    } else if ([supplierId isEqualToString:SDK_ID_Funlink]){
//        clsName = @"FLinkAdSDKManager";
//    }
//    return clsName;
//}

+ (BOOL)isSDKInstalledWithSupplierId:(NSString *)supplierId {
//    NSString *sdkName = [self mappingSDKClassNameWithSupplierId:supplierId];
//    Class sdkClazz = NSClassFromString(sdkName);
//    if (!sdkClazz) {
//        return NO;
//    }
    NSString *adapterName = [self mappingConfigAdapterNameWithSupplierId:supplierId];
    Class adapterClazz = NSClassFromString(adapterName);
    return adapterClazz;
}

@end
