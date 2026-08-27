//
//  AdvAdCacheManager.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/1/29.
//

#import "AdvAdCacheManager.h"
#import "AdvYYCache.h"

@interface AdvAdCacheManager ()
@property (nonatomic, strong) AdvYYCache *adCache;
@property (nonatomic, strong) NSLock *lock;

@end

@implementation AdvAdCacheManager
// MARK: 单例
static AdvAdCacheManager *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        self.adCache = [AdvYYCache cacheWithName:@"AdvanceCacheAd"];
        self.lock = [[NSLock alloc] init];
    }
    return self;
}

- (void)cacheAdapterIfAbsent:(id)adapter
                      price:(NSInteger)price
                 expireTime:(NSInteger)expireTime
                sourceReqId:(NSString *)sourceReqId
                     forKey:(NSString *)key {
    [self.lock lock];
    AdvAdCacheModel *cacheModel = [self.adCache.memoryCache objectForKey:key];
    if (cacheModel && !cacheModel.isCacheValid) {
        [self.adCache.memoryCache removeObjectForKey:key];
        cacheModel = nil;
    }
    if (cacheModel) {
        [self.lock unlock];
        return;
    }
    cacheModel = [[AdvAdCacheModel alloc] init];
    cacheModel.adObject = adapter;
    cacheModel.price = price;
    cacheModel.cachedTimestamp = [[NSDate date] timeIntervalSince1970];
    cacheModel.expireTime = expireTime;
    cacheModel.sourceReqId = sourceReqId;
    [self.adCache.memoryCache setObject:cacheModel forKey:key];
    [self.lock unlock];
}

- (AdvAdCacheModel *)adCacheModelFromCachedKey:(NSString *)key {
    [self.lock lock];
    AdvAdCacheModel *cacheModel = [self.adCache.memoryCache objectForKey:key];
    if (cacheModel && !cacheModel.isCacheValid) { // 缓存过期则移除
        [self.adCache.memoryCache removeObjectForKey:key];
        cacheModel = nil;
    }
    [self.lock unlock];
    return cacheModel;
}

- (void)removeAdCacheModelFromCachedKey:(NSString *)key
                       matchingAdapter:(id)adapter {
    [self.lock lock];
    AdvAdCacheModel *cacheModel = [self.adCache.memoryCache objectForKey:key];
    if (!cacheModel || cacheModel.adObject != adapter) {
        [self.lock unlock];
        return;
    }
    [self.adCache.memoryCache removeObjectForKey:key];
    [self.lock unlock];
}

@end
