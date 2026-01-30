//
//  AdvAdCacheManager.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/1/29.
//

#import <Foundation/Foundation.h>
#import "AdvAdCacheModel.h"

NS_ASSUME_NONNULL_BEGIN
/**
 因无法对三方广告对象进行序列化，故只能实现内存缓存
 */
@interface AdvAdCacheManager : NSObject

+ (instancetype)sharedInstance;

// 缓存广告Adapter对象
- (void)cacheAdapter:(id)adapter
               price:(NSInteger)price
          expireTime:(NSInteger)expireTime
         sourceReqId:(NSString *)sourceReqId
              forKey:(NSString *)key;

// 获取缓存对象
- (AdvAdCacheModel *)adCacheModelFromCachedKey:(NSString *)key;

// 移除缓存对象
- (void)removeAdCacheModelFromCachedKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
