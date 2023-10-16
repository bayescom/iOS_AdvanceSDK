//
//  AdvBaseAdapter.m
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>

@implementation AdvanceBaseAdSpot

- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid
                      customExt:(NSDictionary *)ext {
    if (self = [super init]) {
        _mediaId = mediaId;
        _adspotid = adspotid;
        _ext = [ext mutableCopy];
        _manager = [AdvPolicyService manager];
        _manager.delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
        [self setSDKVersion];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)setSDKVersion {
    [self setGdtSDKVersion];
    [self setCsjSDKVersion];
    [self setMerSDKVersion];
    [self setKsSDKVersion];
    [self setTanxSDKVersion];
}

- (void)setGdtSDKVersion {
    Class clazz = NSClassFromString(@"GDTSDKConfig");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *gdtVersion = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersionForKey:@"gdt_v" version:gdtVersion];
    }
}

- (void)setCsjSDKVersion {
    Class clazz = NSClassFromString(@"BUAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *gdtVersion = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersionForKey:@"csj_v" version:gdtVersion];
    }
}

- (void)setMerSDKVersion {
    Class clazz = NSClassFromString(@"MercuryConfigManager");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *merVersion = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersionForKey:@"mry_v" version:merVersion];
    }
}

- (void)setKsSDKVersion {
    Class clazz = NSClassFromString(@"KSAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *ksVersion = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersionForKey:@"ks_v" version:ksVersion];
    }
}

- (void)setTanxSDKVersion {
    Class clazz = NSClassFromString(@"TXAdSDKConfiguration");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *tanxVersion = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersionForKey:@"tanx_v" version:tanxVersion];
    }
}

- (void)setSDKVersionForKey:(NSString *)key version:(NSString *)version {
    if (version) {
        [_ext setValue:version forKey:key];
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
}

@end
