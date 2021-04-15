//
//  AdvanceNativeExpress.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/13.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvanceNativeExpress.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvLog.h"

@interface AdvanceNativeExpress ()
@property (nonatomic, strong) id adapter;

@end

@implementation AdvanceNativeExpress

- (instancetype)initWithAdspotId:(NSString *)adspotid
                 viewController:(UIViewController *)viewController
                         adSize:(CGSize)size {
    if (self = [super initWithMediaId:@"" adspotId:adspotid customExt:nil]) {
        _viewController = viewController;
        _adSize = size;
    }
    return self;
}

- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(NSDictionary * _Nonnull)ext
                  viewController:(UIViewController *)viewController
                          adSize:(CGSize)size {
    ext = [ext mutableCopy];
    if (!ext) {
        ext = [NSMutableDictionary dictionary];
    }
    [ext setValue:AdvSdkTypeAdNameNativeExpress forKey: AdvSdkTypeAdName];

    if (self = [super initWithMediaId:@"" adspotId:adspotid customExt:ext]) {
        _viewController = viewController;
        _adSize = size;
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
        if (supplier.versionTag == 1) {
            clsName = @"GdtNativeExpressAdapter";
        } else {
            clsName = @"GdtNativeExpressProAdapter";
        }
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjNativeExpressAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryNativeExpressAdapter";
    }
    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        
        if (supplier.isParallel) {
            id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            // 标记当前的adapter 为了让当串行执行到的时候 获取这个adapter
            // 没有设置代理
            ADVLog(@"并行: %@", adapter);
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setController:), _viewController);
            ((void (*)(id, SEL, NSInteger))objc_msgSend)((id)adapter, @selector(setTag:), supplier.priority);
            ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
            if (adapter) {
                // 存储并行的adapter
                [self.arrParallelSupplier addObject:adapter];
            }
        } else {
//            [_adapter performSelector:@selector(deallocAdapter)];
            _adapter = [self adapterInParallelsWithSupplier:supplier];
            if (!_adapter) {
                _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            }
            ADVLog(@"串行 %@ %ld %ld", _adapter, (long)[_adapter tag], supplier.priority);
            // 设置代理
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setController:), _viewController);
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));

        }
        
//        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
//        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setController:), _viewController);
//        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
//        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
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
