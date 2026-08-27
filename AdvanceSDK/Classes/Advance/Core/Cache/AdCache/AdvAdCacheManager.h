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

// 缓存不存在时写入Adapter，判断与写入在同一临界区内完成
- (void)cacheAdapterIfAbsent:(id)adapter
                      price:(NSInteger)price
                 expireTime:(NSInteger)expireTime
                sourceReqId:(NSString *)sourceReqId
                     forKey:(NSString *)key;

// 获取缓存对象
- (AdvAdCacheModel *)adCacheModelFromCachedKey:(NSString *)key;

// 仅当缓存对象与指定Adapter一致时移除，比较与删除在同一临界区内完成
- (void)removeAdCacheModelFromCachedKey:(NSString *)key
                       matchingAdapter:(id)adapter;

@end

NS_ASSUME_NONNULL_END
