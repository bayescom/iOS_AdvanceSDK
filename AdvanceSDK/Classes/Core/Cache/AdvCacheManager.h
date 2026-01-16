//
//  AdvCacheManager.h
//  MercurySDK
//
//  Created by guangyao on 2026/01/16.
//  Copyright © 2025 Mercury. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/**
 因无法对三方广告对象进行序列化，故只能实现内存缓存
 */
@interface AdvCacheManager : NSObject

+ (instancetype)sharedInstance;

// 缓存广告对象
- (void)cacheAdObject:(id)adObject forSupplierKey:(NSString *)supplierKey;

// 获取缓存的广告对象
- (id)adObjectFromCachedKey:(NSString *)supplierKey;

// 移除缓存的广告对象
- (void)removeAdObjectForSupplierKey:(NSString *)supplierKey;


@end

NS_ASSUME_NONNULL_END
