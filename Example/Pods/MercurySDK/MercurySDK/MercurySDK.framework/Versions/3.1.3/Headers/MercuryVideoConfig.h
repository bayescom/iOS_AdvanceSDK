//
//  MercuryVideoConfig.h
//  Example
//
//  Created by CherryKing on 2019/12/26.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MercuryEnumHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface MercuryVideoConfig : NSObject

/// 播放策略
@property (nonatomic, assign) MercuryVideoAutoPlayPolicy videoPlayPolicy;

/// 是否静音播放视频广告，视频初始状态是否静音，默认 YES
@property (nonatomic, assign) BOOL videoMuted;

/// 是否启动自动续播功能，默认 NO
@property (nonatomic, assign) BOOL autoResumeEnable;

/// 是否支持用户点击 MediaView 改变视频播放暂停状态，默认 NO
@property (nonatomic, assign) BOOL userControlEnable;

/// 是否展示播放进度条，默认 YES
@property (nonatomic, assign) BOOL progressViewEnable;

/// 是否展示播放器封面图，默认 YES
@property (nonatomic, assign) BOOL coverImageEnable;

@end

NS_ASSUME_NONNULL_END
