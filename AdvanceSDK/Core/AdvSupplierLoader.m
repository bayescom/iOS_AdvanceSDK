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

@implementation AdvSupplierLoader

// 加载渠道SDK进行初始化调用
+ (void)loadSupplier:(AdvSupplier *)supplier {

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
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SEL selector = NSSelectorFromString(@"registerAppId:");
            if ([clazz.class respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
            }
        });
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {// 穿山甲SDK
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SEL selector = NSSelectorFromString(@"setAppID:");
            if ([clazz.class respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
            }
        });
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {// 倍业SDK
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
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
        });
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {// 快手SDK
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            SEL selector = NSSelectorFromString(@"setAppId:");
            if ([clazz.class respondsToSelector:selector]) {
                ((void (*)(id, SEL, NSString *))objc_msgSend)(clazz.class, selector, supplier.mediaid);
            }
        });

    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {// 百度SDK
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id bdInstance = ((id (*)(id, SEL))objc_msgSend)(clazz, NSSelectorFromString(@"sharedInstance"));
            SEL selector = NSSelectorFromString(@"setSupportHttps:");
            ((void (*)(id, SEL, BOOL))objc_msgSend)(bdInstance, selector, NO);

        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]) {// Tanx
        
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            [clazz performSelector:@selector(setupSDKWithAppID:andAppKey:) withObject:supplier.mediaid withObject:supplier.mediakey];

        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]){
        // bidding 此之前已经对 biddingConfig进行了初始化 并赋值了
        if (!supplier.mediaid) {
            return;
        }
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            if (supplier.mediaid.length > 0) {
                [clazz performSelector:@selector(setupSDKWithAppId:config:) withObject:supplier.mediaid withObject:nil];
            }

        });

    }
}

@end
