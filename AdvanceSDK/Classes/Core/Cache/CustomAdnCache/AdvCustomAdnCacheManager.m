//
//  AdvCustomAdnCacheManager.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/3.
//

#import "AdvCustomAdnCacheManager.h"
#import "AdvYYCache.h"
#import "AdvConstantHeader.h"

/// Adnlist信息缓存key
static NSString * const AdvanceAdnlistInfoKey = @"AdvanceAdnlistInfoKey";

@interface AdvCustomAdnCacheManager ()
@property (nonatomic, strong) AdvYYCache *adnCache;

@end

@implementation AdvCustomAdnCacheManager

// MARK: 单例
static AdvCustomAdnCacheManager *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init];
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    if (self = [super init]) {
        self.adnCache = [AdvYYCache cacheWithName:@"AdvanceCustomAdnCache"];
    }
    return self;
}

- (void)cacheCustomAdnlistInfo:(AdvCustomAdnListInfo *)info {
    NSString *key = [NSString stringWithFormat:@"%@%@", AdvanceAdnlistInfoKey, [AdvDeviceManager sharedInstance].appId];
    [self.adnCache.diskCache setObject:info forKey:key];
}

- (AdvCustomAdnListInfo *)customAdnlistInfo {
    NSString *key = [NSString stringWithFormat:@"%@%@", AdvanceAdnlistInfoKey, [AdvDeviceManager sharedInstance].appId];
    AdvCustomAdnListInfo *info = (AdvCustomAdnListInfo *)[self.adnCache.diskCache objectForKey:key];
    return info;
}

@end
