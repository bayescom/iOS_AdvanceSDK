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

@synthesize mediaId = _mediaId;
@synthesize adspotid = _adspotid;
@synthesize ext = _ext;
@synthesize viewController = _viewController;
@synthesize adapterMap = _adapterMap;
@synthesize targetAdapter = _targetAdapter;
@synthesize manager = _manager;
@synthesize isGroMoreADN = _isGroMoreADN;

- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid
                      customExt:(NSDictionary *)ext {
    if (self = [super init]) {
        _mediaId = mediaId;
        _adspotid = adspotid;
        _ext = ext;
        _manager = [AdvPolicyService manager];
        _manager.delegate = self;
        _adapterMap = [NSMutableDictionary dictionary];
        [self setupAllSDKVersion];
    }
    return self;
}

- (void)loadAdPolicy {
    [_manager loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)catchBidTargetWhenGroMoreBiddingWithPolicyModel:(AdvPolicyModel *)model {
    [_manager catchBidTargetWhenGroMoreBiddingWithPolicyModel:model];
}

- (void)setupAllSDKVersion {
    [self setGdtSDKVersion];
    [self setCsjSDKVersion];
    [self setMercurySDKVersion];
    [self setKsSDKVersion];
    [self setTanxSDKVersion];
    [self setBaiduSDKVersion];
    [self setSigmobSDKVersion];
}

- (void)setGdtSDKVersion {
    Class clazz = NSClassFromString(@"GDTSDKConfig");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"gdt_v"];
    }
}

- (void)setCsjSDKVersion {
    Class clazz = NSClassFromString(@"BUAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"csj_v"];
    }
}

- (void)setMercurySDKVersion {
    Class clazz = NSClassFromString(@"MercuryConfigManager");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"mry_v"];
    }
}

- (void)setKsSDKVersion {
    Class clazz = NSClassFromString(@"KSAdSDKManager");
    SEL selector = NSSelectorFromString(@"SDKVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"ks_v"];
    }
}

- (void)setTanxSDKVersion {
    Class clazz = NSClassFromString(@"TXAdSDKConfiguration");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"tanx_v"];
    }
}

- (void)setBaiduSDKVersion {
    Class clazz = NSClassFromString(@"BaiduMobAdSetting");
    id bdInstance = ((id (*)(id, SEL))objc_msgSend)(clazz.class, NSSelectorFromString(@"sharedInstance"));
    SEL selector = NSSelectorFromString(@"getSDKVersion");
    if ([bdInstance respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(bdInstance, selector);
        [self setSDKVersion:version forKey:@"bd_v"];
    }
}

- (void)setSigmobSDKVersion {
    Class clazz = NSClassFromString(@"WindAds");
    SEL selector = NSSelectorFromString(@"sdkVersion");
    if (clazz && [clazz.class respondsToSelector:selector]) {
        NSString *version = ((NSString* (*)(id, SEL))objc_msgSend)(clazz.class, selector);
        [self setSDKVersion:version forKey:@"sig_v"];
    }
}

- (void)setSDKVersion:(NSString *)version forKey:(NSString *)key {
    if (version) {
        [_ext setValue:version forKey:key];
    }
}

- (void)dealloc {
    ADVLog(@"%s %@", __func__, self);
}

@end
