//
//  AdvCustomAdnCacheManager.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/6/3.
//

#import <Foundation/Foundation.h>
#import "AdvCustomAdnModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvCustomAdnCacheManager : NSObject

+ (instancetype)sharedInstance;

// 缓存自定义Adnlist信息
- (void)cacheCustomAdnlistInfo:(AdvCustomAdnListInfo *)info;

// 获取缓存自定义Adnlist信息
- (AdvCustomAdnListInfo *)customAdnlistInfo;

@end

NS_ASSUME_NONNULL_END
