//
//  AdvBaseAdapter.m
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import "AdvBaseAdapter.h"
#import "AdvSupplierManager.h"
#import "AdvanceSupplierDelegate.h"
#import "AdvSdkConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface AdvBaseAdapter ()  <AdvSupplierManagerDelegate, AdvanceSupplierDelegate>
@property (nonatomic, strong) AdvSupplierManager *mgr;

@property (nonatomic, weak) id<AdvanceSupplierDelegate> baseDelegate;

@end

@implementation AdvBaseAdapter

-  (instancetype)initWithMediaId:(NSString *)mediaId
                        adspotId:(NSString *)adspotid {
    return [self initWithMediaId:mediaId adspotId:adspotid customExt:nil];
}

- (instancetype)initWithMediaId:(NSString *)mediaId
                       adspotId:(NSString *)adspotid
                      customExt:(NSDictionary *)ext {
    if (self = [super init]) {
        _mediaId = mediaId;
        _adspotid = adspotid;
        _ext = [ext mutableCopy];
    }
    return self;
}

- (void)loadAd {
    [self.mgr loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)loadNextSupplierIfHas {
    NSLog(@"aaaaaaaaa");
    [_mgr loadNextSupplierIfHas];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(NSError *)error {
    // 有错误正常上报
    [_mgr reportWithType:repoType supplier:supplier error:error];
    
    // 失败了 并且不是并行才会走下一个渠道
    if (repoType == AdvanceSdkSupplierRepoFaileded && !supplier.isParallel) {
        NSLog(@"bbbbbbbbbb %@  %@",supplier.sdktag, error);
        [_mgr loadNextSupplierIfHas];
    }
}

- (void)deallocAdapter {
    [self.mgr cacelDataTask];
    self.mgr = nil;
    self.baseDelegate = nil;
    
}

- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
                                adspotId:(NSString *)adspotid
                                mediaKey:(NSString *)mediakey
                                   sdkId:(nonnull NSString *)sdkid {
    [self.mgr setDefaultAdvSupplierWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
}

// MARK: ======================= AdvSupplierManagerDelegate =======================
/// 加载策略Model成功
- (void)advSupplierManagerLoadSuccess:(AdvSupplierModel *)model {
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadSuccess:)]) {
        [_baseDelegate advanceBaseAdapterLoadSuccess:model];
    }
}

/// 加载策略Model失败
- (void)advSupplierManagerLoadError:(NSError *)error {
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadError:)]) {
        [_baseDelegate advanceBaseAdapterLoadError:error];
    }
}

/// 返回下一个渠道的参数
- (void)advSupplierLoadSupplueryyyyy:(AdvSupplier *)supplier queue:(AdvSupplierQueue *)queue error:(NSError *)error {

    // 初始化渠道参数
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"BUAdSDKManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryConfigManager";
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
            [NSClassFromString(clsName) performSelector:@selector(setAppID:) withObject:supplier.mediaid];//
        });
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        // MercurySDK
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            id configMgr = NSClassFromString(clsName);
            ((void (*)(id, SEL, id, id, id))objc_msgSend)(configMgr, @selector(setAppID:mediaKey:config:), supplier.mediaid, supplier.mediakey, [AdvSdkConfig shareInstance].caidConfig);
//            ((void (*)(id, SEL, id))objc_msgSend)(configMgr, @selector(openDebug:), @1);
        });
    }
    
    // 如果执行了打底渠道 则执行此方法
    if ([supplier.sdktag isEqualToString:@"bottom_default"]) {
        [self advSupplierLoadDefaultSuppluer:supplier];
    }

    // 加载渠道
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadSuppluerxxxxxx:queue:error:)]) {
//        NSLog(@"xxxxerror: %@   clsName: %@", error, clsName);
        [_baseDelegate advanceBaseAdapterLoadSuppluerxxxxxx:supplier queue:queue error:error];
    }
}


/// 返回下一个渠道的参数
- (void)advSupplierLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {

    // 初始化渠道参数
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GDTSDKConfig";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"BUAdSDKManager";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryConfigManager";
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
            [NSClassFromString(clsName) performSelector:@selector(setAppID:mediaKey:) withObject:supplier.mediaid withObject:supplier.mediakey];
        });
    }

    // 如果执行了打底渠道 则执行此方法
    if ([supplier.sdktag isEqualToString:@"bottom_default"]) {
        [self advSupplierLoadDefaultSuppluer:supplier];
    }

    // 加载渠道
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadSuppluer:error:)]) {
//        NSLog(@"xxxxerror: %@   clsName: %@", error, clsName);
        [_baseDelegate advanceBaseAdapterLoadSuppluer:supplier error:error];
    }
}

// MARK: ======================= get =======================
- (AdvSupplierManager *)mgr {
    if (!_mgr) {
        _mgr = [AdvSupplierManager manager];
        _mgr.delegate = self;
        _baseDelegate = self;
    }
    return _mgr;
}

@end
