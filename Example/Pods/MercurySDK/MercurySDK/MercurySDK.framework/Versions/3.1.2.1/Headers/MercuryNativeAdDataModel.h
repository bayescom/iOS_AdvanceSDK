//
//  MercuryNativeAdDataModel.h
//  Example
//
//  Created by CherryKing on 2019/11/20.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryVideoConfig.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryNativeAdDataModel : NSObject
@property (nonatomic, copy, readonly)   NSString *adsource;
@property (nonatomic, copy, readonly)   NSString *logo;
@property (nonatomic, copy, readonly)   NSString *title;
@property (nonatomic, copy, readonly)   NSArray<NSString *> *image;
@property (nonatomic, copy, readonly)   NSString *desc;

/// 视频广告播放配置
@property (nonatomic, strong) MercuryVideoConfig *videoConfig;

/// 是否为视频广告
@property (nonatomic, assign, readonly) BOOL isVideoAd;

@end

NS_ASSUME_NONNULL_END
