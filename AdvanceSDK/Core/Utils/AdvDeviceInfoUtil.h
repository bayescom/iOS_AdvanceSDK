//
//  AdvDeviceInfoUtil.h
//  advancelib
//
//  Created by allen on 2019/9/11.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AdvDeviceInfoUtil : NSObject

+ (NSString *)getIdfa;
+ (NSString *)getAuctionId;

+ (NSMutableDictionary *)getDeviceInfoWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId;

+ (NSMutableDictionary *)getSDKTrackEventDeviceInfoWithMediaId:(NSString *)mediaId adspotId:(NSString *)adspotId;

@end

NS_ASSUME_NONNULL_END
