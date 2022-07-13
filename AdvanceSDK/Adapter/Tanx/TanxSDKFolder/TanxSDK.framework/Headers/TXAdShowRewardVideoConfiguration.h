//
//  TXAdShowRewardVideoConfiguration.h
//  TanxSDK
//
//  Created by Yueyang Gu on 2022/6/17.
//  Copyright © 2022 tanx.com. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, TXAdRewardVideoDefaultAudioState) {
    // 以有声状态开始播放
    TXAdRewardVideoDefaultAudioStateVocal = 0,
    // 以静音状态开始播放
    TXAdRewardVideoDefaultAudioStateMuted,
};

@interface TXAdShowRewardVideoConfiguration : NSObject

/// 激励视频开始播放时，音频默认状态，可设成以静音状态开始播放。
@property(nonatomic, assign) TXAdRewardVideoDefaultAudioState defaultAudioState;

@end

NS_ASSUME_NONNULL_END
