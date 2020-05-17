//
//  AdvanceBannerProtocol.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#ifndef AdvanceBannerProtocol_h
#define AdvanceBannerProtocol_h

#if __has_include(<MercurySDK/AdvanceBaseDelegate.h>)
#import <MercurySDK/AdvanceBaseDelegate.h>
#else
#import "AdvanceBaseDelegate.h"
#endif

@protocol AdvanceBannerDelegate <AdvanceBaseDelegate>
@optional

/// 请求广告数据成功后调用
- (void)advanceBannerOnAdReceived;

/// 广告曝光回调
- (void)advanceBannerOnAdShow;

/// 广告点击回调
- (void)advanceBannerOnAdClicked;

/// 广告展示失败
- (void)advanceBannerOnAdFailedWithSdkId:(NSString *)sdkId error:(NSError *)error;

/// 广告关闭回调
- (void)advanceBannerOnAdClosed;


@end

#endif
