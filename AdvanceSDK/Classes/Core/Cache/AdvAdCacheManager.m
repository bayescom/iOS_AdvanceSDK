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

@end

@implementation AdvAdCacheManager
// MARK: 单例
static AdvAdCacheManager *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    return _instance ;
}

- (instancetype)init {
    if (self = [super init]) {
        self.adCache = [AdvYYCache cacheWithName:@"AdvanceCacheAd"];
    }
    return self;
}

// 缓存广告Adapter对象
- (void)cacheAdapter:(id)adapter
               price:(NSInteger)price
          expireTime:(NSInteger)expireTime
         sourceReqId:(NSString *)sourceReqId
              forKey:(NSString *)key {
    // 创建广告缓存对象
    AdvAdCacheModel *cacheModel = [[AdvAdCacheModel alloc] init];
    cacheModel.adObject = adapter;
    cacheModel.price = price;
    cacheModel.cachedTimestamp = [[NSDate date] timeIntervalSince1970];
    cacheModel.expireTime = expireTime;
    cacheModel.sourceReqId = sourceReqId;
    [self.adCache.memoryCache setObject:cacheModel forKey:key];
}

- (AdvAdCacheModel *)adCacheModelFromCachedKey:(NSString *)key {
    AdvAdCacheModel *cacheModel = [self.adCache.memoryCache objectForKey:key];
    if (cacheModel && !cacheModel.isCacheValid) { // 缓存过期则移除
        [self removeAdCacheModelFromCachedKey:key];
        return nil;
    }
    return cacheModel;
}

- (void)removeAdCacheModelFromCachedKey:(NSString *)key {
    [self.adCache.memoryCache removeObjectForKey:key];
}

@end
