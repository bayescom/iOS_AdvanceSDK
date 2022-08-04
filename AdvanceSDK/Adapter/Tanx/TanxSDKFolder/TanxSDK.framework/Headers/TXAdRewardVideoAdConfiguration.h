//
//  TXAdRewardVideoAdConfiguration.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/6/29.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TXAdRewardVideoAdConfiguration : NSObject

/// loadAd超时时间，默认没有超时时间，单位秒
@property(nonatomic, assign) NSTimeInterval loadAdTimeoutInterval;

@end

NS_ASSUME_NONNULL_END
