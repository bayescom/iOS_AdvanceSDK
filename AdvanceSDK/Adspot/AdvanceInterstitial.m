//
//  AdvanceInterstitial.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceInterstitial.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvLog.h"

@interface AdvanceInterstitial ()
@property (nonatomic, strong) id adapter;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation AdvanceInterstitial

- (instancetype)initWithAdspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController {
    return [self initWithAdspotId:adspotid customExt:nil viewController:viewController];
}

- (instancetype)initWithAdspotId:(NSString *)adspotid customExt:(NSDictionary * _Nonnull)ext viewController:(nonnull UIViewController *)viewController{
    if (self = [super initWithMediaId:nil adspotId:adspotid customExt:ext]) {
        _viewController = viewController;
    }
    return self;
}

// 执行了打底渠道
- (void)advSupplierLoadDefaultSuppluer:(AdvSupplier *)supplier
{
    ADVLog(@"执行了打底渠道: %@", supplier.sdktag);
    [self advanceOnAdReceivedWithReqId:supplier.sdktag];
}

// 返回策略id
- (void)advanceOnAdReceivedWithReqId:(NSString *)reqId
{
    if ([_delegate respondsToSelector:@selector(advanceOnAdReceived:)]) {
        [_delegate advanceOnAdReceived:reqId];
    }
}

// MARK: ======================= AdvanceSupplierDelegate =======================
/// 加载策略Model成功
- (void)advanceBaseAdapterLoadSuccess:(nonnull AdvSupplierModel *)model {
//    if ([_delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
//        [_delegate advanceSplashOnAdReceived];
//    }
    [self advanceOnAdReceivedWithReqId:model.reqid];
}

/// 加载策略Model失败
- (void)advanceBaseAdapterLoadError:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(advanceFailedWithError:)]) {
        [_delegate advanceFailedWithError:error];
    }
}

/// 返回下一个渠道的参数
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        ADVLog(@"%@", error);
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(advanceFailedWithError:)]) {
            [self.delegate advanceFailedWithError:error];
        }
        return;
    }
    // 开始加载渠道前通知调用者
    if ([self.delegate respondsToSelector:@selector(advanceSupplierWillLoad:)]) {
        [self.delegate advanceSupplierWillLoad:supplier.identifier];
    }

    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryInterstitialAdapter";
    }
    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
    } else {
        ADVLog(@"%@ 不存在", clsName);
        [self loadNextSupplierIfHas];
    }
}

- (void)showAd {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(showAd));
#pragma clang diagnostic pop
}

@end
