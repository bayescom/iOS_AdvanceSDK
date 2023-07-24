//
//  AdvBaseAdapter.m
//  Demo
//
//  Created by CherryKing on 2020/11/20.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvSupplierManager.h"
#import "AdvanceSupplierDelegate.h"
#import "AdvLog.h"
#import "AdvSdkConfig.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvanceAESCipher.h"

@interface AdvanceBaseAdSpot ()

@property (nonatomic, strong) AdvSupplierManager *mgr;

@end

@implementation AdvanceBaseAdSpot

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
        _mgr = [AdvSupplierManager manager];
        _mgr.delegate = self;
        _arrParallelSupplier = [NSMutableArray array];
        _errorDescriptions = [NSMutableDictionary dictionary];

    }
    return self;
}

- (void)loadAd {
    if (_isUploadSDKVersion) {
        [self setSDKVersion];
    }
    [_mgr loadDataWithMediaId:_mediaId adspotId:_adspotid customExt:_ext];
}

/// 加载策略
- (void)loadAdWithSupplierModel:(AdvSupplierModel *)model {
    [_mgr loadDataWithSupplierModel:model];
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
    
    // 瀑布流的广告位 进入瀑布流的队列
    if (repoType == AdvanceSdkSupplierRepoBidding && supplier.positionType == AdvanceSdkSupplierTypeWaterfall) {
        [_mgr inWaterfallQueueWithSupplier:supplier];
    }
     
    // headBidding 广告位进入headBidding队列
    if (repoType == AdvanceSdkSupplierRepoBidding && supplier.positionType == AdvanceSdkSupplierTypeHeadBidding) {
//        NSLog(@"|||111--- %@ %ld %@",supplier.sdktag, (long)supplier.priority, supplier);
        [_mgr inHeadBiddingQueueWithSupplier:supplier];
    }

    
    
    // 失败了 并且不是并行才会走下一个渠道
    // 由于bidding渠道isParallel=yes 所以bidding是不会走这个逻辑的
    // 但是bidding结束后会选择一个胜出的渠道, 胜出的渠道isParallel = NO 所以会走这个逻辑
    if (repoType == AdvanceSdkSupplierRepoFailed && !supplier.isParallel) {
//        NSLog(@"%@ |||   %ld %@",supplier.sdktag, (long)supplier.priority, supplier);
        
        // 如果渠道非并发 且不支持bidding 且失败了, 则为原来的业务渠道, 走原来的业务逻辑
        if (supplier.positionType == AdvanceSdkSupplierTypeWaterfall) {
            // 执行下一个渠道
            
            [_mgr loadNextSupplierIfHas];
        } else {
            // 如果走到了这里, 则意味着 最后胜出的渠道, 加载下一组bidding
            [_mgr loadNextWaterfallSupplierIfHas];
        }
    }

    // 如果并发渠道失败了 要通知mananger那边 _inwaterfallcount -1
    if (repoType == AdvanceSdkSupplierRepoFailed && supplier.isParallel) {
        [_mgr inParallelWithErrorSupplier:supplier];
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
    // 该方法为AdvanceSDK 内部调用 开发者不要在外部手动调用 想要释放 直接将广告对象置为nil即可
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
    _mgr.delegate = nil;
    [_arrParallelSupplier removeAllObjects];
    _arrParallelSupplier = nil;
    [_mgr cancelDataTask];
    _mgr = nil;
}

- (void)setSDKVersion {
    [self setGdtSDKVersion];
    [self setCsjSDKVersion];
    [self setMerSDKVersion];
    [self setKsSDKVersion];
    [self setTanxSDKVersion];
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

- (void)setTanxSDKVersion {
    id cls = NSClassFromString(@"TXAdSDKConfiguration");
    NSString *tanxVersion = [cls performSelector:@selector(sdkVersion)];
    
    [self setSDKVersionForKey:@"tanx_v" version:tanxVersion];
}


- (void)setSDKVersionForKey:(NSString *)key version:(NSString *)version {
    if (version) {
        [_ext setValue:version forKey:key];
    }
}


// 查找一下 容器里有没有并行的渠道
- (id)adapterInParallelsWithSupplier:(AdvSupplier *)supplier {
    id adapterT;
    for (NSInteger i = 0 ; i < _arrParallelSupplier.count; i++) {
        
        id temp = _arrParallelSupplier[i];
        NSInteger tag = ((NSInteger (*)(id, SEL))objc_msgSend)((id)temp, @selector(tag));
        if (tag == supplier.priority) {
            adapterT = temp;
        }
    }
    return adapterT;
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
    [self deallocAdapter];
}

@end
