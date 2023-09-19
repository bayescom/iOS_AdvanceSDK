//
//  AdvSupplierLoader.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/7/24.
//

#import "AdvSupplierLoader.h"
#import "AdvSdkConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvanceAESCipher.h"
#import "AdvBayesSDKConfig.h"

@interface AdvSupplierLoader ()

@property (nonatomic, strong) NSMutableDictionary *initializedDict;

@end

@implementation AdvSupplierLoader

static AdvSupplierLoader *instance = nil;

+(instancetype)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

-(instancetype)init {
    if (self = [super init]) {
        _initializedDict = [NSMutableDictionary dictionary];
    }
    return self;
}


// 加载渠道SDK进行初始化调用
+ (void)loadSupplier:(AdvSupplier *)supplier completion:(void (^)(void))completion {
    
    if ([[[AdvSupplierLoader defaultInstance].initializedDict objectForKey:supplier.identifier] boolValue]) {
        completion();
        return;
    }
    
    /// 渠道初始化标记
    [[AdvSupplierLoader defaultInstance].initializedDict setObject:@YES forKey:supplier.identifier];
    
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"BUAdSDKManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryConfigManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {
        clsName = @"KSAdSDKManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]){
        clsName = @"BaiduMobAdSetting";
    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]){
        clsName = @"TXAdSDKInitializtion";
    } else if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]){
        clsName = @"ABUAdSDKManager";
    }
    
    Class clazz = NSClassFromString(clsName);
    
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {// 广点通SDK
        
        SEL selector = NSSelectorFromString(@"registerAppId:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
            completion();
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {// 穿山甲SDK
        
        id config = ((id (*)(id, SEL))objc_msgSend)(NSClassFromString(@"BUAdSDKConfiguration").class, NSSelectorFromString(@"configuration"));
        ((void (*)(id, SEL, NSString *))objc_msgSend)(config, NSSelectorFromString(@"setAppID:"), supplier.mediaid);
        // 定义block
        void (^completionHandler)(BOOL success, NSError *error) = ^void (BOOL success, NSError *error) {
            if (success && completion) {
                completion();
            }
        };
        SEL selector = NSSelectorFromString(@"startWithAsyncCompletionHandler:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, selector, completionHandler);
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {// 倍业SDK
        
        // 初始化
        SEL selector = NSSelectorFromString(@"setAppID:appKey:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid, supplier.mediakey);
        }
        // 设置AAID
        NSString *aliMediaId = [AdvBayesSDKConfig sharedInstance].aliMediaId;
        NSString *aliMediaSecret = [AdvBayesSDKConfig sharedInstance].aliMediaSecret;
        if (aliMediaId.length > 0 && aliMediaSecret.length > 0) {
            SEL selector = NSSelectorFromString(@"setAAIDWithMediaId:mediaSecret:");
            if ([clazz.class respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSString *, NSString *))objc_msgSend)(clazz.class, selector, aliMediaId, aliMediaSecret);
            }
        }
        // 设置UA
        NSString *userAgent = [AdvBayesSDKConfig sharedInstance].userAgent;
        if (userAgent.length > 0) {
            NSString *uaEncrypt = advanceAesEncryptString(userAgent, AdvanceSDKSecretKey);
            SEL selector = NSSelectorFromString(@"setDefaultUserAgent:");
            if ([clazz.class respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, uaEncrypt);
            }
        }
        completion();
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {// 快手SDK
        
        SEL selector = NSSelectorFromString(@"setAppId:");
        if ([clazz.class respondsToSelector:selector]) {
            ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
            completion();
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {// 百度SDK
        
        id bdInstance = ((id (*)(id, SEL))objc_msgSend)(clazz, NSSelectorFromString(@"sharedInstance"));
        SEL selector = NSSelectorFromString(@"setSupportHttps:");
        if ([bdInstance respondsToSelector:selector]) {
            ((void (*)(id, SEL, BOOL))objc_msgSend)(bdInstance, selector, NO);
            completion();
        }
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]) {// Tanx
        
        [clazz performSelector:@selector(setupSDKWithAppID:andAppKey:) withObject:supplier.mediaid withObject:supplier.mediakey];
        completion();
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]){
        // bidding 此之前已经对 biddingConfig进行了初始化 并赋值了
        if (!supplier.mediaid) {
            return;
        }
        if (supplier.mediaid.length > 0) {
            [clazz performSelector:@selector(setupSDKWithAppId:config:) withObject:supplier.mediaid withObject:nil];
            completion();
        }
    }
    
}

@end
