//
//  AdvCacheManager.m
//  MercurySDK
//
//  Created by guangyao on 2026/01/16.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import "AdvCacheManager.h"
#import "AdvYYCache.h"

@interface AdvCacheManager ()
@property (nonatomic, strong) AdvYYCache *adCache;

@end

@implementation AdvCacheManager
// MARK: 单例
static AdvCacheManager *_instance = nil;
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

- (void)cacheAdObject:(id)adObject forSupplierKey:(NSString *)supplierKey {
    [self.adCache.memoryCache setObject:adObject forKey:supplierKey];
}

- (id)adObjectFromCachedKey:(NSString *)supplierKey {
    return [self.adCache.memoryCache objectForKey:supplierKey];
}

- (void)removeAdObjectForSupplierKey:(NSString *)supplierKey {
    [self.adCache.memoryCache removeObjectForKey:supplierKey];
}

@end
