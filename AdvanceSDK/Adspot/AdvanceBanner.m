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
    return [self initWithAdspotId:adspotid adContainer:adContainer customExt:nil viewController:viewController];
}

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                       customExt:(NSDictionary * _Nonnull)ext
                  viewController:(nonnull UIViewController *)viewController {
    if (self = [super initWithMediaId:@"" adspotId:adspotid customExt:ext]) {
        _adContainer = adContainer;
        _viewController = viewController;
        _refreshInterval = 30;
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
        // 错误回调只调用一次
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
        // 1. 如果是并行渠道, 则生成一个adapter并标记渠道
        // 2. 将生成的adapter 存储到容器中保持其广告加载的流程
        // 3. 等到串行队列执行到该渠道的时候 直接载入这个adapter的加载流程里
        if (supplier.isParallel) {
            id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            // 标记当前的adapter 为了让当串行执行到的时候 获取这个adapter
            // 没有设置代理
            ((void (*)(id, SEL, id))objc_msgSend)((id)adapter, @selector(setAdspotid:), supplier.adspotid);
            ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
            ADVLog(@"并行: %@", adapter);

            if (adapter) {
                // 存储并行的adapter
                [self.arrParallelSupplier addObject:adapter];
            }

        } else {
            // 1. 先移除上一个失败的渠道
            // 2. 先看看当前执行的串行渠道 是不是之前的并行渠道
            // 3. 如果不是之前的并行渠道 则为 其他串行渠道
            // 4. 如果是之前的并行渠道, 直接载入
            [_adapter performSelector:@selector(deallocAdapter)];
            _adapter = [self adapterInParallelsWithSupplier:supplier];
            if (!_adapter) {
                _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            }
            ADVLog(@"串行 %@", _adapter);
            // 设置代理
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
        }
//        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
//        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
//        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
    } else {
        NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
        ADVLog(@"%@", msg);
        [self loadNextSupplierIfHas];
    }
}






//NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1000;
//if ((_timeout_stamp > 0) && (now+500 > _timeout_stamp)
//    && !(supplier.state == AdvanceSdkSupplierStateSuccess || supplier.state == AdvanceSdkSupplierStateFailed)) {
//    // 1. 串行时如果前面的渠道加载时间过长 导致后面的渠道加载时间不足(还剩0.5s) 则默认下面的渠道无法加载成功, 直接清空view 结束此次广告加载流程
//    // 2. 并行时,如果有结果了(成功或者失败) 则不应移除
//    ADVLog(@"总时长到了, 该清空了");
//    [self deallocSelf]; //清空view 重置解释器
//    [self deallocDelegate:YES];// 向外回调错误
//} else {
//    if (NSClassFromString(clsName)) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//        // 1. 如果是并行渠道, 则生成一个adapter并标记渠道
//        // 2. 将生成的adapter 存储到容器中保持其广告加载的流程
//        // 3. 等到串行队列执行到该渠道的时候 直接载入这个adapter的加载流程里
//        if (supplier.isParallel) {
//            id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
//            // 标记当前的adapter 为了让当串行执行到的时候 获取这个adapter
//            // 没有设置代理
//            ((void (*)(id, SEL, id))objc_msgSend)((id)adapter, @selector(setAdspotid:), supplier.adspotid);
//            ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
//            ADVLog(@"并行: %@", adapter);
//
//            if (adapter) {
//                // 存储并行的adapter
//                [self.arrParallelSupplier addObject:adapter];
//            }
//
//        } else {
//            // supplier.state 的意义是标记并行渠道
//            // 如果串行队列 执行到的渠道是并行渠道时 则依然要修改其超时时间
//            if (supplier.state != AdvanceSdkSupplierStateSuccess && supplier.state != AdvanceSdkSupplierStateFailed) {
//
//            } else {
//                supplier.timeout = (_timeout_stamp - now) >= 5000 ? 5000 : (_timeout_stamp - now);
//            }
//
//            // 1. 先移除上一个失败的渠道
//            // 2. 先看看当前执行的串行渠道 是不是之前的并行渠道
//            // 3. 如果不是之前的并行渠道 则为 其他串行渠道
//            // 4. 如果是之前的并行渠道, 直接载入
//            [_adapter performSelector:@selector(deallocAdapter)];
//            _adapter = [self adapterInParallelsWithSupplier:supplier];
//            if (!_adapter) {
//                _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
//            }
//            ADVLog(@"串行 %@", _adapter);
//            // 设置代理
//            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
//            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
//        }
//#pragma clang diagnostic pop
//    } else {
//        NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
//        ADVLog(@"%@", msg);
//        [self loadNextSupplierIfHas];
//    }
//}






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
