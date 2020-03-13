//
//  MercuryEnumHeader.h
//  Example
//
//  Created by CherryKing on 2019/12/9.
//  Copyright © 2019 CherryKing. All rights reserved.
//

#ifndef MercuryEnumHeader_h
#define MercuryEnumHeader_h

typedef NS_ENUM(NSUInteger, MercuryMediaPlayerStatus) {
    MercuryMediaPlayerStatusInitial  = 0,         // 初始状态
    MercuryMediaPlayerStatusLoading  = 1,         // 加载中
    MercuryMediaPlayerStatusStarted  = 2,         // 开始播放
    MercuryMediaPlayerStatusPaused   = 3,         // 用户行为导致暂停
    MercuryMediaPlayerStatusStoped   = 4,         // 播放停止
    MercuryMediaPlayerStatusError    = 5,         // 播放出错
};

typedef NS_ENUM(NSUInteger, MercuryNativeExpressAdSizeMode) {
    /// 自动按照给出容器的宽度计算高度
    MercuryNativeExpressAdSizeModeAutoSize = 0,
    /// 超出父容器的部分会被截取
    MercuryNativeExpressAdSizeModeMask,
};

typedef NS_ENUM(NSInteger, MercuryVideoAutoPlayPolicy) {
    MercuryVideoAutoPlayPolicyWIFI   = 0, // WIFI 下自动播放
    MercuryVideoAutoPlayPolicyAlways = 1, // 总是自动播放，无论网络条件
    MercuryVideoAutoPlayPolicyNever  = 2, // 从不自动播放，无论网络条件
};

#endif
