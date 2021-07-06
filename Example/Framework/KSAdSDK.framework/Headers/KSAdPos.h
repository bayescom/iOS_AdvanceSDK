//
//  KSAdPos.h
//  KSAdSDK
//
//  Created by 徐志军 on 2019/11/14.
//  Copyright © 2019 KuaiShou. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, KSAdPosAdType) {
    KSAdPosAdTypeUnknown            =       0,
    KSAdPosAdTypeFeed               =       1,
    KSAdPosAdTypeRewardVideo        =       2,
    KSAdPosAdTypeFullScreenVideo    =       3,
    KSAdPosAdTypeSplash             =       4,
    KSAdPosAdTypeDrawVideo          =       6,
    KSAdPosAdTypeContentEcology     =       7,
    KSAdPosAdTypeBanner             =       8,
    KSAdPosAdTypePaster             =       10,
    KSAdPosAdTypeInterstitial       =       13,
};

typedef NS_ENUM(NSInteger, KSAdPosPosition) {
    KSAdPosPositionTop = 1,
    KSAdPosPositionBottom = 2,
    KSAdPosPositionFeed = 3,
    KSAdPosPositionMiddle = 4,
    KSAdPosPositionFullScreen = 5,
};

