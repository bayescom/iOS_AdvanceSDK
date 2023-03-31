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

- (instancetype)initWithAdspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController adSize:(CGSize)adSize {
    return [self initWithAdspotId:adspotid customExt:nil viewController:viewController adSize:adSize];
}

- (instancetype)initWithAdspotId:(NSString *)adspotid customExt:(NSDictionary * _Nonnull)ext viewController:(nonnull UIViewController *)viewController adSize:(CGSize)adSize{
    ext = [ext mutableCopy];
    if (!ext) {
        ext = [NSMutableDictionary dictionary];
    }
    [ext setValue:AdvSdkTypeAdNameInterstitial forKey: AdvSdkTypeAdName];
    if (self = [super initWithMediaId:@"" adspotId:adspotid customExt:ext]) {
        _viewController = viewController;
        _adSize = adSize;
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

// 开始bidding
- (void)advanceBaseAdapterBiddingAction:(NSMutableArray <AdvSupplier *> *_Nullable)suppliers {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(advanceBiddingAction)]) {
//        [self.delegate advanceBiddingAction];
//    }
}

// bidding结束
- (void)advanceBaseAdapterBiddingEndWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
//    if (self.delegate && [self.delegate respondsToSelector:@selector(advanceBiddingEnd)]) {
//        [self.delegate advanceBiddingEnd];
//    }
}

/// 返回下一个渠道的参数
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
//        ADVLog(@"%@", error);
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(advanceFailedWithError:description:)]) {
            [self.delegate advanceFailedWithError:error description:[self.errorDescriptions copy]];
        }
        [self deallocDelegate:NO];
        return;
    }
    if (supplier.isParallel == NO) {// 只有当串行队列执行该渠道时 才会回调用代理 并行渠道不调用该代理
        // 开始加载渠道前通知调用者
        if ([self.delegate respondsToSelector:@selector(advanceSupplierWillLoad:)]) {
            [self.delegate advanceSupplierWillLoad:supplier.identifier];
        }
    }

    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_KS]) {
        clsName = @"KsInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"BdInterstitialAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_BIDDING]) {
        clsName = @"AdvBiddingInterstitialAdapter";
    }
    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        if (supplier.isParallel) {
            id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            // 标记当前的adapter 为了让当串行执行到的时候 获取这个adapter
            // 没有设置代理
//            ADVLog(@"并行: %@", adapter);
            ((void (*)(id, SEL, NSInteger))objc_msgSend)((id)adapter, @selector(setTag:), supplier.priority);
            ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
            if (adapter) {
                // 存储并行的adapter
                [self.arrParallelSupplier addObject:adapter];
            }
        } else {
            [_adapter performSelector:@selector(deallocAdapter)];
            _adapter = [self adapterInParallelsWithSupplier:supplier];
            if (!_adapter) {
                _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
            }
//            ADVLog(@"串行 %@ %ld %ld", _adapter, (long)[_adapter tag], supplier.priority);
            // 设置代理
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
        }
#pragma clang diagnostic pop
    } else {
//        ADVLog(@"%@ 不存在", clsName);
        [self loadNextSupplierIfHas];
    }
}

- (void)deallocDelegate:(BOOL)execute {
    if(execute) {
        [_adapter performSelector:@selector(deallocAdapter)];
        [self deallocAdapter];
    }
    _delegate = nil;
}


- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s %@ %@", __func__, _adapter , self);
    _adapter = nil;
}

- (void)showAd {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(showAd));
#pragma clang diagnostic pop
}

@end
