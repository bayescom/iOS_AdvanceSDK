//
//  AdvAdCacheModel.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/1/29.
//

#import "AdvAdCacheModel.h"

@implementation AdvAdCacheModel

- (BOOL)isCacheValid {
    NSInteger currentTimestamp = [[NSDate date] timeIntervalSince1970];
    return _cachedTimestamp + _expireTime > currentTimestamp;
}

@end
