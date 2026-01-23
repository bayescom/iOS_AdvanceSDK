//
//  AdvSupplierLoader.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import "AdvSupplierLoader.h"
#import "AdvConstantHeader.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvError.h"

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
+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(void))completion {
    /// 已经初始化过的渠道 直接返回成功
    if ([[AdvSupplierLoader.initializedDict objectForKey:supplier.identifier] boolValue]) {
        return completion();
    }
    
    /// 未被引入的渠道SDK或Adapter已在策略层过滤 这里的Clazz必存在
    NSString *clsName = [self mappingSDKClassNameWithSupplierId:supplier.identifier];
    Class clazz = NSClassFromString(clsName);
    
    if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {// 穿山甲SDK
        
        id config = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"BUAdSDKConfiguration").class, NSSelectorFromString(@"configuration"));
        ((void (*)(id, SEL, NSString *))objc_msgSend)(config, NSSelectorFromString(@"setAppID:"), supplier.mediaid);
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            /// 穿山甲是异步初始化，回调需要切换到主线程
            dispatch_async(dispatch_get_main_queue(), ^{
                [self markSupplierInitialized:supplier error:error];
                completion();
            });
        };
        SEL selector = NSSelectorFromString(@"startWithAsyncCompletionHandler:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, selector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {// 广点通SDK
        /// 4.14.60（包含）版本之后初始化方式
        SEL initSelector = NSSelectorFromString(@"initWithAppId:");
        if ([clazz.class respondsToSelector:initSelector]) {
            ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, initSelector, supplier.mediaid);
        }
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            [self markSupplierInitialized:supplier error:error];
            completion();
        };
        SEL newSelector = NSSelectorFromString(@"startWithCompletionHandler:");
        if ([clazz.class respondsToSelector:newSelector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, newSelector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {// 快手SDK
        /// 3.3.61（包含）版本之后初始化方式
        id config = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"KSAdSDKConfiguration").class, NSSelectorFromString(@"configuration"));
        ((void (*)(id, SEL, NSString *))objc_msgSend)(config, NSSelectorFromString(@"setAppId:"), supplier.mediaid);
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            [self markSupplierInitialized:supplier error:error];
            completion();
        };
        SEL newSelector = NSSelectorFromString(@"startWithCompletionHandler:");
        if ([clazz.class respondsToSelector:newSelector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, newSelector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {// 百度SDK
        /// 新初始化方式
        SEL selector = NSSelectorFromString(@"setAppsid:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
        }
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            [self markSupplierInitialized:supplier error:error];
            completion();
        };
        SEL newSelector = NSSelectorFromString(@"startWithCompletionHandler:");
        if ([clazz.class respondsToSelector:newSelector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, newSelector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {// 倍业SDK
        /// 4.4.0（包含）版本之后初始化方式
        SEL initSelector = NSSelectorFromString(@"initWithAppId:appKey:");
        if ([clazz.class respondsToSelector:initSelector]) {
            ((void (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz.class, initSelector, supplier.mediaid, supplier.mediakey);
        }
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            [self markSupplierInitialized:supplier error:error];
            completion();
        };
        SEL newSelector = NSSelectorFromString(@"startWithCompletionHandler:");
        if ([clazz.class respondsToSelector:newSelector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, newSelector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]) {// Tanx SDK
        
        SEL selector = NSSelectorFromString(@"setupSDKWithAppID:andAppKey:");
        if ([clazz.class respondsToSelector:selector]) {
            BOOL res = ((BOOL (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid, supplier.mediakey);
            NSError *error = res? nil : [AdvError errorWithCode:-100 message:@"TanxSDK初始化失败"].toNSError;
            [self markSupplierInitialized:supplier error:error];
            completion();
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_Sigmob]) {// Sigmob SDK
        
        id option = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"WindAdOptions"), NSSelectorFromString(@"alloc"));
        SEL selector = NSSelectorFromString(@"initWithAppId:appKey:");
        if ([option respondsToSelector:selector]) {
            id optionInstance =  ((id (*)(id, SEL, NSString *, NSString *))objc_msgSend)(option, selector, supplier.mediaid, supplier.mediakey);
            SEL startSelector = NSSelectorFromString(@"startWithOptions:");
            if ([clazz.class respondsToSelector:startSelector]) {
                ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, startSelector, optionInstance);
                [self markSupplierInitialized:supplier error:nil];
                completion();
            }
        }
    }
    
}

/// 标记渠道已经被初始化
+ (void)markSupplierInitialized:(AdvSupplier *)supplier error:(NSError *)error {
    if (!error) {
        [AdvSupplierLoader.initializedDict setObject:@YES forKey:supplier.identifier];
        return;
    }
    AdvLog(@"%@渠道SDK初始化失败:%@",supplier.name, error);
}

+ (NSString *)mappingSDKClassNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"BUAdSDKManager";
    } if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"KSAdSDKManager";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]){
        clsName = @"BaiduMobAdManager";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryConfigManager";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]){
        clsName = @"TXAdSDKInitializtion";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]){
        clsName = @"WindAds";
    }
    return clsName;
}

+ (NSString *)mappingSplashAdapterClassNameWithSupplierId:(NSString *)supplierId {
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
    }
    return clsName;
}

+ (NSString *)mappingInterstitialAdapterClassNameWithSupplierId:(NSString *)supplierId {
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
    }
    return clsName;
}

+ (NSString *)mappingRewardAdapterClassNameWithSupplierId:(NSString *)supplierId {
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
    }
    return clsName;
}

+ (NSString *)mappingFullScreenAdapterClassNameWithSupplierId:(NSString *)supplierId {
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

+ (BOOL)isSDKInstalledWithSupplierId:(NSString *)supplierId {
    NSString *sdkName = [self mappingSDKClassNameWithSupplierId:supplierId];
    Class sdkClazz = NSClassFromString(sdkName);
    if (!sdkClazz) {
        return NO;
    }
    NSString *adapterName = [self mappingSplashAdapterClassNameWithSupplierId:supplierId];
    Class adapterClazz = NSClassFromString(adapterName);
    return adapterClazz;
}

@end
