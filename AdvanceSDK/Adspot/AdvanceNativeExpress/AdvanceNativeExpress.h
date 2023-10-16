//
//  AdvanceNativeExpress.h
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceBaseAdSpot.h"
#import "AdvanceNativeExpressDelegate.h"

NS_ASSUME_NONNULL_BEGIN

/// 模板渲染信息流广告
@interface AdvanceNativeExpress : AdvanceBaseAdSpot

/// 广告方法回调代理
@property (nonatomic, weak) id<AdvanceNativeExpressDelegate> delegate;

/// 素材尺寸
@property (nonatomic, assign) CGSize adSize;

/// 设定是否静音播放视频，默认为YES
@property(nonatomic, assign) BOOL muted;

/// 构造函数
/// @param adspotid adspotid
/// @param ext 自定义拓展参数
/// @param viewController viewController
/// @param size 尺寸
- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)size;

-(void)loadAd;

@end

NS_ASSUME_NONNULL_END
