//
//  AdvAdCacheModel.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/1/29.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvAdCacheModel : NSObject
// 广告对象
@property (nonatomic, strong) id adObject;
// 广告价格
@property (nonatomic, assign) NSInteger price;
// 广告缓存时间戳（秒）
@property (nonatomic, assign) NSInteger cachedTimestamp;
// 广告缓存过期时间（秒）
@property (nonatomic, assign) NSInteger expireTime;
// 缓存广告的源reqid
@property (nonatomic, copy) NSString *sourceReqId;
// 当前缓存是否有效（未过期）
@property (nonatomic, assign, readonly) BOOL isCacheValid;

@end

NS_ASSUME_NONNULL_END
