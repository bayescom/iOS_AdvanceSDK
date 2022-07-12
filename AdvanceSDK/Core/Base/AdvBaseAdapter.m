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
    if (_isUploadSDKVersion) {
        [self setSDKVersion];
    }
    [self.mgr loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

- (void)loadNextSupplierIfHas {
    [_mgr loadNextSupplierIfHas];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(AdvSupplier *)supplier error:(NSError *)error {
//    NSLog(@"|||--- %@ %ld %@",supplier.sdktag, (long)supplier.priority, supplier);
    [_mgr reportWithType:repoType supplier:supplier error:error];
    
    // 搜集各渠道的错误信息
    if (error) {
        [self collectErrorWithSupplier:supplier error:error];
    }

    
    // 如果是bidding渠道,且上报类型是bidding, 那么就加入bidding队列 (bidding的渠道一定是并发的, isParallel一定为yes)
    // 注意: 每个渠道返回价格的时机不一样 广点通 didload就可以返回, 详见 AdvSupplier.supplierPrice 的说明
    if (repoType == AdvanceSdkSupplierRepoBidding && supplier.isSupportBidding) {
        [_mgr inBiddingQueueWithSupplier:supplier];
    }
    
    
    // 失败了 并且不是并行才会走下一个渠道
    // 由于bidding渠道isParallel=yes 所以bidding是不会走这个逻辑的
    // 但是bidding结束后会选择一个胜出的渠道, 胜出的渠道isParallel = NO 所以会走这个逻辑
    if (repoType == AdvanceSdkSupplierRepoFaileded && !supplier.isParallel) {
        NSLog(@"%@ |||   %ld %@",supplier.sdktag, (long)supplier.priority, supplier);
        
        // 如果渠道非并发 且不支持bidding 且失败了, 则为原来的业务渠道, 走原来的业务逻辑
        if (supplier.isSupportBidding == NO) {
            // 执行下一个渠道
            [_mgr loadNextSupplierIfHas];
        } else {
            // 如果走到了这里, 则意味着 最后胜出的渠道,展示失败  现阶段只抛异常,  下阶段,要在这里执行gromore的逻辑
//            if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadError:)]) {
//                [_baseDelegate advanceBaseAdapterLoadError:error];
//            }
            // 加载下一组bidding
            [_mgr loadNextBiddingSupplierIfHas];
        }
    }

}

// 开始bidding
- (void)advManagerBiddingActionWithSuppliers:(NSMutableArray<AdvSupplier *> *)suppliers {
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(advanceBaseAdapterBiddingAction:)]) {
        [self.baseDelegate advanceBaseAdapterBiddingAction:suppliers];
    }
}

// bidding结束
- (void)advManagerBiddingEndWithWinSupplier:(AdvSupplier *)winSupplier {
    // 抛出去 下个版本会在每个广告位的 advanceBaseAdapterBiddingEndWithWinSupplier 里 执行GroMore的逻辑
    if (self.baseDelegate && [self.baseDelegate respondsToSelector:@selector(advanceBaseAdapterBiddingEndWithWinSupplier:)]) {
        [self.baseDelegate advanceBaseAdapterBiddingEndWithWinSupplier:winSupplier];
    }
}

- (void)collectErrorWithSupplier:(AdvSupplier *)supplier error:(NSError *)error {
    // key: 渠道名-优先级
    if (error) {
        NSString *key = [NSString stringWithFormat:@"%@-%ld",supplier.name, supplier.priority];
        [self.errorDescriptions setObject:error forKey:key];
    }
}

- (void)deallocAdapter {
    [self.mgr cacelDataTask];
    self.mgr = nil;
    self.baseDelegate = nil;
    
}

//- (void)setDefaultAdvSupplierWithMediaId:(NSString *)mediaId
//                                adspotId:(NSString *)adspotid
//                                mediaKey:(NSString *)mediakey
//                                   sdkId:(nonnull NSString *)sdkid {
//    [self.mgr setDefaultAdvSupplierWithMediaId:mediaId adspotId:adspotid mediaKey:mediakey sdkId:sdkid];
//}

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
- (void)advSupplierLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {

    
    // 初始化渠道参数
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
            [bdSetting performSelector:@selector(setSupportHttps:) withObject:NO];

        });
    } else {
        
    }

    // 加载渠道
    if ([_baseDelegate respondsToSelector:@selector(advanceBaseAdapterLoadSuppluer:error:)]) {
        [_baseDelegate advanceBaseAdapterLoadSuppluer:supplier error:error];
    }
}

- (void)setSDKVersion {
    [self setGdtSDKVersion];
    [self setCsjSDKVersion];
    [self setMerSDKVersion];
    [self setKsSDKVersion];
}

- (void)setGdtSDKVersion {
    id cls = NSClassFromString(@"GDTSDKConfig");
    NSString *gdtVersion = [cls performSelector:@selector(sdkVersion)];
    
    [self setSDKVersionForKey:@"gdt_v" version:gdtVersion];
}

- (void)setCsjSDKVersion {
    id cls = NSClassFromString(@"BUAdSDKManager");
    NSString *csjVersion = [cls performSelector:@selector(SDKVersion)];
    
    [self setSDKVersionForKey:@"csj_v" version:csjVersion];
}

- (void)setMerSDKVersion {
    id cls = NSClassFromString(@"MercuryConfigManager");
    NSString *merVersion = [cls performSelector:@selector(sdkVersion)];

    [self setSDKVersionForKey:@"mry_v" version:merVersion];
}

- (void)setKsSDKVersion {
    id cls = NSClassFromString(@"KSAdSDKManager");
    NSString *ksVersion = [cls performSelector:@selector(SDKVersion)];
    
    [self setSDKVersionForKey:@"ks_v" version:ksVersion];
}


- (void)setSDKVersionForKey:(NSString *)key version:(NSString *)version {
    if (version) {
        [_ext setValue:version forKey:key];
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

- (NSMutableArray *)arrParallelSupplier {
    if (!_arrParallelSupplier) {
        _arrParallelSupplier = [NSMutableArray array];
    }
    return _arrParallelSupplier;
}

- (NSMutableDictionary *)errorDescriptions {
    if (!_errorDescriptions) {
        _errorDescriptions = [NSMutableDictionary dictionary];
    }
    return _errorDescriptions;;
}

// 查找一下 容器里有没有并行的渠道
- (id)adapterInParallelsWithSupplier:(AdvSupplier *)supplier {
    id adapterT;
    for (NSInteger i = 0 ; i < self.arrParallelSupplier.count; i++) {
        
        id temp = self.arrParallelSupplier[i];
        NSInteger tag = ((NSInteger (*)(id, SEL))objc_msgSend)((id)temp, @selector(tag));
        if (tag == supplier.priority) {
            adapterT = temp;
        }
    }
    return adapterT;
}


@end
