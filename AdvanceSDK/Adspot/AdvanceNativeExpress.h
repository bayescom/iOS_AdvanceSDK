//
//  AdvanceNativeExpress.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvBaseAdapter.h"

#import <UIKit/UIKit.h>

#import "AdvSdkConfig.h"
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface AdvanceNativeExpress : AdvBaseAdapter
/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) CGSize adSize;
///  设定是否静音播放视频，YES = 静音，NO = 非静音 默认为YES
/*
PS:
①仅gdt、ks、支持设定mute
②仅适用于视频播放器设定生效
 (只对客户端可以控制的部分生效, 有些需要到网盟后台去设置比如穿山甲)
重点：请在loadAd前设置,否则不生效
*/

@property(nonatomic, assign) BOOL muted;

- (instancetype)initWithAdspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)size;


/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
/// @param size 尺寸
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(NSDictionary *_Nonnull)ext
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
