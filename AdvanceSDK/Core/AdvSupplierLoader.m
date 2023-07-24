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

@implementation AdvSupplierLoader

static AdvSupplierLoader *instance = nil;

+(instancetype)defaultInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

// 加载渠道SDK进行初始化调用
- (void)loadSupplier:(AdvSupplier *)supplier extra:(NSDictionary *)extra {

    // 初始化渠道SDK
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
    

    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        // 广点通SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            
            [NSClassFromString(clsName) performSelector:@selector(registerAppId:) withObject:supplier.mediaid];
        });
        
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        // 穿山甲SDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppID:) withObject:supplier.mediaid];
        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        // MercurySDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = NSClassFromString(clsName);
            [cls performSelector:@selector(setAppID:mediaKey:) withObject:supplier.mediaid withObject:supplier.mediakey];
            
            NSString *ua = [extra objectForKey:AdvanceSDKUaKey];
            if (ua) {
                NSString *uaEncrypt = advanceAesEncryptString(ua, AdvanceSDKSecretKey);

                [cls performSelector:@selector(setDefaultUserAgent:) withObject:uaEncrypt];
            }
        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {
        // 快手
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            [NSClassFromString(clsName) performSelector:@selector(setAppId:) withObject:supplier.mediaid];
        });

    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {
        // 百度
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id bdSetting = ((id(*)(id,SEL))objc_msgSend)(NSClassFromString(clsName), @selector(sharedInstance));
            [bdSetting performSelector:@selector(setSupportHttps:) withObject:@NO];

        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_TANX]) {
        // Tanx
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{

            [NSClassFromString(clsName) performSelector:@selector(setupSDKWithAppID:andAppKey:) withObject:supplier.mediaid withObject:supplier.mediakey];

        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]){
        // bidding 此之前已经对 biddingConfig进行了初始化 并赋值了
        if (!supplier.mediaid) {
            return;
        }
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            BOOL isEmpty = [self isEmptyString:supplier.mediaid];
            if (isEmpty == NO) {
                [NSClassFromString(clsName) performSelector:@selector(setupSDKWithAppId:config:) withObject:supplier.mediaid withObject:nil];
            }
            
            // Gromore SDK初始化方法
//            [ABUAdSDKManager setupSDKWithAppId:supplier.mediaid config:^ABUUserConfig *(ABUUserConfig *c) {
//        #ifdef DEBUG
//                // 打开日志开关，线上环境请关闭
//                c.logEnable = YES;
//                // 打开测试模式，线上环境请关闭
////                c.testMode = YES;
//        #endif
//                return c;
//            }];

        });

    }
}

- (BOOL)isEmptyString:(NSString *)string{
       if(string == nil) {
            return YES;
        }
        if (string == NULL) {
            return YES;
        }
        if ([string isKindOfClass:[NSNull class]]) {
            return YES;
        }
        if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
            return YES;
        }
    return NO;
}

@end
