//
//  AdvanceNativeExpress.h
//  advancelib
//
//  Created by allen on 2019/12/31.
//  Copyright © 2019 Bayescom. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AdvanceBaseAdspot.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AdvanceNativeExpressDelegate <NSObject>
@optional
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(nullable NSArray<UIView *> *)views;

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(nullable UIView *)adView;

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(nullable UIView *)adView;

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(nullable UIView *)adView;

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(nullable UIView *)adView;

/// 广告被关闭
- (void)advanceNativeExpressOnAdClosed:(nullable UIView *)adView;

/// 广告数据拉取失败
- (void)advanceNativeExpressOnAdFailed;

@end

@interface AdvanceNativeExpress : AdvanceBaseAdspot
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) CGSize adSize;

- (instancetype)initWithMediaId:(NSString *)mediaid
                       adspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController
                         adSize:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
