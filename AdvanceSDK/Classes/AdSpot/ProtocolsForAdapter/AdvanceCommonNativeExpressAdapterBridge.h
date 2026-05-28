//
//  AdvanceCommonNativeExpressAdapterBridge.h
//  AdvanceSDK
//
//  Created by guangyao on 2026/5/27.
//

@protocol AdvanceCommonNativeExpressAdapter;

/// 模板渲染信息流广告adapter的回调协议
@protocol AdvanceCommonNativeExpressAdapterBridge <NSObject>

- (void)nativeExpress_didLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter price:(NSInteger)price;

- (void)nativeExpress_failedToLoadAdWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter error:(NSError *)error;

- (void)nativeExpress_didAdRenderSuccessWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView;

- (void)nativeExpress_didAdRenderFailWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView error:(NSError *)error;

- (void)nativeExpress_didAdExposuredWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView;

- (void)nativeExpress_didAdClickedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView;

- (void)nativeExpress_didAdClosedWithAdapter:(id<AdvanceCommonNativeExpressAdapter>)adapter expressView:(UIView *)expressView;

@end

