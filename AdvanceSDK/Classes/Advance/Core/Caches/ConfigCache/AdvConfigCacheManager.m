
#import "AdvConfigCacheManager.h"
#import "AdvDeviceManager.h"
#import "AdvYYCache.h"
#import "AdvPolicyModel.h"

/// SDK通用配置信息缓存key
static NSString * const AdvanceSDKConfigKey = @"AdvanceSDKConfigKey";
/// 策略模型缓存Key
static NSString * const AdvancePolicyCacheKey = @"AdvancePolicyCacheKey";

@interface AdvConfigCacheManager ()
@property (nonatomic, strong) AdvYYCache *configCache;
@property (nonatomic, strong) NSLock *policyCacheLock;

@end

@implementation AdvConfigCacheManager

// MARK: 单例
static AdvConfigCacheManager *_instance = nil;
+ (instancetype) sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[super allocWithZone:NULL] init] ;
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    if (self = [super init]) {
        self.configCache = [AdvYYCache cacheWithName:@"AdvanceSDKConfig"];
        self.policyCacheLock = [[NSLock alloc] init];
    }
    return self;
}

- (void)cacheSDKConfig:(AdvanceSDKConfig *)config {
    NSString *key = [NSString stringWithFormat:@"%@%@", AdvanceSDKConfigKey, [AdvDeviceManager sharedInstance].appId];
    [self.configCache setObject:config forKey:key];
}

- (AdvanceSDKConfig *)sdkConfig {
    NSString *key = [NSString stringWithFormat:@"%@%@", AdvanceSDKConfigKey, [AdvDeviceManager sharedInstance].appId];
    AdvanceSDKConfig *config = (AdvanceSDKConfig *)[self.configCache objectForKey:key];
    return config;
}

#pragma mark - 策略缓存
- (void)cachePolicyModel:(AdvPolicyModel *)model forAdspotId:(NSString *)adspotId {
    NSString *key = [self policyCacheKeyForAdspotId:adspotId];
    if (!key.length || !model) {
        return;
    }

    [self.policyCacheLock lock];
    model.strategyCachedTimestamp = [NSDate date].timeIntervalSince1970;
    [self.configCache.diskCache setObject:model forKey:key];
    [self.policyCacheLock unlock];
}

- (nullable AdvPolicyModel *)policyModelForAdspotId:(NSString *)adspotId {
    NSString *key = [self policyCacheKeyForAdspotId:adspotId];
    if (!key.length) {
        return nil;
    }

    // 将读取、有效期校验和失效删除放在同一临界区，避免误删并发写入的新策略。
    [self.policyCacheLock lock];
    AdvPolicyModel *model = (AdvPolicyModel *)[self.configCache.diskCache objectForKey:key];
    NSTimeInterval currentTimestamp = [NSDate date].timeIntervalSince1970;
    if (model && model.strategyCachedTimestamp + model.setting.strategy_cache_duration <= currentTimestamp) {
        [self.configCache.diskCache removeObjectForKey:key];
        model = nil;
    }
    [self.policyCacheLock unlock];
    return model;
}

- (nullable NSString *)policyCacheKeyForAdspotId:(NSString *)adspotId {
    NSString *appId = [AdvDeviceManager sharedInstance].appId;
    if (!appId.length || !adspotId.length) {
        return nil;
    }
    // 长度前缀避免 App ID、广告位 ID 自身包含分隔符时发生 key 碰撞。
    return [NSString stringWithFormat:@"%@:%lu:%@:%@", AdvancePolicyCacheKey,
            (unsigned long)appId.length, appId, adspotId];
}

@end
