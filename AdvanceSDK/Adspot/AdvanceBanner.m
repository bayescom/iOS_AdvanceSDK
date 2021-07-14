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
    if ([_delegate respondsToSelector:@selector(advanceFailedWithError:description:)]) {
        [_delegate advanceFailedWithError:error description:[self.errorDescriptions copy]];
    }
}

/// 返回下一个渠道的参数
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        // 错误回调只调用一次
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(advanceFailedWithError:description:)]) {
            [self.delegate advanceFailedWithError:error description:[self.errorDescriptions copy]];
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
    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"BdBannerAdapter";
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


@end
