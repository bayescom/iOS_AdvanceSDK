#import "AdvanceBaseAdSpot.h"
#import "AdvLog.h"
#import "AdvPolicyService.h"
#import "AdvConstantHeader.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvanceBaseAdSpot () <AdvPolicyServiceDelegate>

@end

@implementation AdvanceBaseAdSpot

@synthesize adspotid = _adspotid;
@synthesize reqId = _reqId;
@synthesize extraDict = _extraDict;
@synthesize adapterMap = _adapterMap;
@synthesize targetAdapter = _targetAdapter;
@synthesize manager = _manager;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                           extra:(NSDictionary *)extra {
    if (self = [super init]) {
        _adspotid = adspotid;
        _extraDict = [extra mutableCopy];
        _reqId = [AdvDeviceManager getUUID];
        _manager = [AdvPolicyService manager];
        ((AdvPolicyService *)_manager).delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
        [self setupAllSDKVersion];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadPolicyDataWithAdspotId:_adspotid reqId:_reqId extra:_extraDict.copy];
}

- (void)destroyAdapters {
    self.adapterMap = nil;
    self.manager = nil;
}

- (void)setupAllSDKVersion {
    [self setGDTSDKVersion];
    [self setCSJSDKVersion];
    [self setMercurySDKVersion];
    [self setKSSDKVersion];
    [self setBaiduSDKVersion];
    [self setTanxSDKVersion];
    [self setSigmobSDKVersion];
}

- (void)setGDTSDKVersion {
    Class clazz = NSClassFromString(@"GDTSDKConfig");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"gdt_v"];
    }
}

- (void)setCSJSDKVersion {
    Class clazz = NSClassFromString(@"BUAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"csj_v"];
    }
}

- (void)setMercurySDKVersion {
    Class clazz = NSClassFromString(@"MercuryConfigManager");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"mry_v"];
    }
}

- (void)setKSSDKVersion {
    Class clazz = NSClassFromString(@"KSAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"ks_v"];
    }
}

- (void)setBaiduSDKVersion {
    Class clazz = NSClassFromString(@"BaiduMobAdManager");
    SEL selector = NSSelectorFromString(@"getSDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"bd_v"];
    }
}

- (void)setTanxSDKVersion {
    Class clazz = NSClassFromString(@"TXAdSDKConfiguration");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"tanx_v"];
    }
}

- (void)setSigmobSDKVersion {
    Class clazz = NSClassFromString(@"WindAds");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [_extraDict adv_safeSetObject:version forKey:@"sig_v"];
    }
}

- (void)dealloc {
    
}

@end
