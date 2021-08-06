//
//  AdvanceNativeExpressView.h
//  AdvanceSDK
//
//  Created by MS on 2021/8/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class AdvanceNativeExpressView;
@protocol AdvanceNativeExpressDelegate <AdvanceCommonDelegate>
@optional
/// 广告数据拉取成功
- (void)advanceNativeExpressOnAdLoadSuccess:(nullable NSArray<UIView *> *)views;
/// 测试
- (void)advanceNativeExpressOnAdLoadSuccess123:(nullable NSArray<AdvanceNativeExpressView *> *)views;

/// 广告曝光
- (void)advanceNativeExpressOnAdShow:(nullable UIView *)adView;

/// 广告点击
- (void)advanceNativeExpressOnAdClicked:(nullable UIView *)adView;

/// 广告渲染成功
- (void)advanceNativeExpressOnAdRenderSuccess:(nullable UIView *)adView;

/// 广告渲染失败
- (void)advanceNativeExpressOnAdRenderFail:(nullable UIView *)adView;

/// 广告被关闭 (注: 百度广告(百青藤), 不支持该回调, 若使用百青藤,则该回到功能请自行实现)
- (void)advanceNativeExpressOnAdClosed:(nullable UIView *)adView;

@end

@interface AdvanceNativeExpressView : NSObject
// 信息流view
@property (nonatomic, strong) UIView *expressView;

// 渠道标识
@property (nonatomic, copy) NSString *identifier;

- (void)render;
@end

NS_ASSUME_NONNULL_END
