//
//  AdvanceBanner.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceBanner.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvLog.h"

@interface AdvanceBanner ()
@property (nonatomic, strong) id adapter;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation AdvanceBanner

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                  viewController:(nonnull UIViewController *)viewController {
    if (self = [super initWithMediaId:nil adspotId:adspotid]) {
        _adContainer = adContainer;
        _viewController = viewController;
        _refreshInterval = 30;
    }
    return self;
}

// MARK: ======================= AdvanceSupplierDelegate =======================
/// 加载策略Model成功
- (void)advanceBaseAdapterLoadSuccess:(nonnull AdvSupplierModel *)model {
//    if ([_delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
//        [_delegate advanceSplashOnAdReceived];
//    }
}

/// 加载策略Model失败
- (void)advanceBaseAdapterLoadError:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
        [_delegate advanceOnAdNotFilled:error];
    }
}

/// 返回下一个渠道的参数
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        ADVLog(@"%@", error);
        return;
    }
    
    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtBannerAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjBannerAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryBannerAdapter";
    }
    ADVLog(@"%@ | %@", supplier.name, clsName);

    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
    } else {
        NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
        ADVLog(@"%@", msg);
        [self loadNextSupplierIfHas];
    }
}

//// MARK: ======================= AdvanceBaseAdspotDelegate =======================
///// 加载渠道广告，将会返回渠道所需参数
///// @param sdkId 渠道ID
///// @param params 渠道参数
//- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
//    // 根据渠道id自定义初始化
//    NSString *clsName = @"";
//    if ([sdkId isEqualToString:SDK_ID_GDT]) {
//        clsName = @"GdtBannerAdapter";
//    } else if ([sdkId isEqualToString:SDK_ID_CSJ]) {
//        clsName = @"CsjBannerAdapter";
//    } else if ([sdkId isEqualToString:SDK_ID_MERCURY]) {
//        clsName = @"MercuryBannerAdapter";
//    }
//    if (NSClassFromString(clsName)) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), params, self);
//        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
//        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
//#pragma clang diagnostic pop
//    } else {
//        ADVLog(@"%@ 不存在", clsName);
//    }
//}
//
///// 策略请求失败
///// @param error 失败原因
//- (void)advanceOnAdNotFilled:(NSError *)error {
//    if ([_delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
//        [_delegate advanceOnAdNotFilled:error];
//    }
//}

@end
