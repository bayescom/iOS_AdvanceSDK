//
//  AdvanceSplash.m
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import <objc/runtime.h>
#import <objc/message.h>

#import "AdvanceSplash.h"
#import "AdvanceSupplierDelegate.h"
#import "AdvSupplierModel.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import "AdvError.h"

@interface AdvanceSplash ()
@property (nonatomic, strong) id adapter;

@property (nonatomic, strong) UIImageView *bgImgV;

@property (nonatomic, assign) NSInteger timeout_stamp;
@property (nonatomic, strong) CADisplayLink *timeoutCheckTimer;
@property (nonatomic, strong) NSMutableArray * arrParallelSupplier;
@property (nonatomic, assign) BOOL testII;

@end

@implementation AdvanceSplash

- (instancetype)initWithAdspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController {
    return [self initWithAdspotId:adspotid customExt:nil viewController:viewController];
}

- (instancetype)initWithAdspotId:(NSString *)adspotid customExt:(NSDictionary *)ext viewController:(UIViewController *)viewController {
    if (self = [super initWithMediaId:@"" adspotId:adspotid customExt:ext]) {
        _viewController = viewController;
    }
    return self;
}

- (void)loadAd {
    // 占位图
    [[UIApplication sharedApplication].adv_getCurrentWindow addSubview:self.bgImgV];
        
    if (_timeout <= 0) { _timeout = 60; }
    // 记录过期的时间
    _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + _timeout)*1000;
    // 开启定时器监听过期
//    [_timeoutCheckTimer invalidate];
//
//    _timeoutCheckTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeoutCheckTimerAction)];
//    [_timeoutCheckTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    [super loadAd];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType supplier:(nonnull AdvSupplier *)supplier error:(nonnull NSError *)error {
    [super reportWithType:repoType supplier:supplier error:error];
    if (repoType == AdvanceSdkSupplierRepoImped) {
        [_timeoutCheckTimer invalidate];
        _timeoutCheckTimer = nil;
        [_bgImgV removeFromSuperview];
        _bgImgV = nil;
    }
}

/// Override
- (void)deallocSelf {
    [_bgImgV removeFromSuperview];
    [_timeoutCheckTimer invalidate];
    _timeoutCheckTimer = nil;
    _timeout_stamp = 0;
}

- (void)deallocDelegate:(BOOL)execute {
    
    if([_delegate respondsToSelector:@selector(advanceFailedWithError:)] && execute) {
        [_delegate advanceFailedWithError:[AdvError errorWithCode:AdvErrorCode_115].toNSError];
        [_adapter performSelector:@selector(deallocAdapter)];
        [self deallocAdapter];
    }
    _delegate = nil;
}

// 无论怎样到达超时时间时  都必须移除开屏广告
- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
        [self deallocDelegate:YES];
        [self deallocSelf];
    }
}

// 执行了打底渠道
- (void)advSupplierLoadDefaultSuppluer:(AdvSupplier *)supplier
{
//    ADVLog(@"执行了打底渠道: %@", supplier.sdktag);
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
    // 返回策略id
    [self advanceOnAdReceivedWithReqId:model.reqid];
}

/// 加载策略Model失败
- (void)advanceBaseAdapterLoadError:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(advanceFailedWithError:)]) {
        [_delegate advanceFailedWithError:error];
    }
//    [self deallocSelf]; // 注释掉 是因为在执行打底渠道
}




- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        ADVLog(@"%@", error);
        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(advanceFailedWithError:)]) {
            [self.delegate advanceFailedWithError:error];
        }
        [self deallocSelf];
        [self deallocDelegate:NO];
        return;
    }

    if (supplier.isParallel == NO) {// 只有当优先级执行该渠道时 才会回调用代理 并行渠道不调用该代理
        // 开始加载渠道前通知调用者
        if ([self.delegate respondsToSelector:@selector(advanceSupplierWillLoad:)]) {
            [self.delegate advanceSupplierWillLoad:supplier.identifier];
        }
    }

    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtSplashAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjSplashAdapter";
    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercurySplashAdapter";
    }
    ADVLog(@"%@ | %@", supplier.name, clsName);
    // 请求超时了
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1000;
    if ((_timeout_stamp > 0) && (now+500 > _timeout_stamp)) {
        [self deallocSelf]; //清空view 重置解释器
        [self deallocDelegate:YES];// 向外回调错误
    } else {
        supplier.timeout = (_timeout_stamp - now) >= 5000 ? 5000 : (_timeout_stamp - now);
        if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            if (supplier.isParallel) {
                id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
                // 标记当前的adapter 为了让当串行执行到的时候 获取这个adapter
                ((void (*)(id, SEL, id))objc_msgSend)((id)adapter, @selector(setAdspotid:), supplier.adspotid);
                ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
                NSLog(@"并行行%@", adapter);

                if (adapter) {
                    // 存储并行的adapter

                    [self.arrParallelSupplier addObject:adapter];
                }

            } else {
                // :先看看当前执行的串行渠道 是不是之前的并行渠道
                if (!_testII) {
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
//                        NSLog(@"延时模拟串行%@", _adapter);
                        [_adapter performSelector:@selector(deallocAdapter)];
                        _adapter = [self adapterInParallelsWithSupplier:supplier];
                        if (!_adapter) {
                            _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
                        }
                        NSLog(@"串行11%@", _adapter);

                        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
                        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));

//                    });
                    _testII = YES;
                } else {
                    NSLog(@"串行%@", _adapter);
                    [_adapter performSelector:@selector(deallocAdapter)];
                    _adapter = [self adapterInParallelsWithSupplier:supplier];
                    if (!_adapter) {
                        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
                    }
                    NSLog(@"串行11%@", _adapter);

                    ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
                    ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
                }
            }
#pragma clang diagnostic pop
        } else {
            NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
            ADVLog(@"%@", msg);
            [self loadNextSupplierIfHas];
        }
    }
}

- (id)adapterInParallelsWithSupplier:(AdvSupplier *)supplier {
    id adapterT;
    for (NSInteger i = 0 ; i < self.arrParallelSupplier.count; i++) {
        
        id temp = self.arrParallelSupplier[i];
        NSString *adspotid = ((NSString* (*)(id, SEL))objc_msgSend)((id)temp, @selector(adspotid));
        if ([adspotid isEqualToString:supplier.adspotid]) {
            adapterT = temp;
        }
    }
    return adapterT;
}

/// 返回下一个渠道的参数
//- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
//    // 返回渠道有问题 则不用再执行下面的渠道了
//    if (error) {
//        ADVLog(@"%@", error);
//        if (self.delegate != nil && [self.delegate respondsToSelector:@selector(advanceFailedWithError:)]) {
//            [self.delegate advanceFailedWithError:error];
//        }
//        [self deallocSelf];
//        return;
//    }
//
//    // 开始加载渠道前通知调用者
//    if ([self.delegate respondsToSelector:@selector(advanceSupplierWillLoad:)]) {
//        [self.delegate advanceSupplierWillLoad:supplier.identifier];
//    }
//
//    // 根据渠道id自定义初始化
//    NSString *clsName = @"";
//    if ([supplier.identifier isEqualToString:SDK_ID_GDT]) {
//        clsName = @"GdtSplashAdapter";
//    } else if ([supplier.identifier isEqualToString:SDK_ID_CSJ]) {
//        clsName = @"CsjSplashAdapter";
//    } else if ([supplier.identifier isEqualToString:SDK_ID_MERCURY]) {
//        clsName = @"MercurySplashAdapter";
//    }
//    ADVLog(@"%@ | %@", supplier.name, clsName);
//    // 请求超时了
//    NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1000;
//    if ((_timeout_stamp > 0) && (now+500 > _timeout_stamp)) {
//        [self deallocSelf];
//    } else {
//        supplier.timeout = (_timeout_stamp - now) >= 5000 ? 5000 : (_timeout_stamp - now);
//        if (NSClassFromString(clsName)) {
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wundeclared-selector"
//            [_adapter performSelector:@selector(deallocAdapter)];
//            _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
//            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
//            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
//#pragma clang diagnostic pop
//        } else {
//            NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
//            ADVLog(@"%@", msg);
//            [self loadNextSupplierIfHas];
//        }
//    }
//}

// MARK: ======================= get =======================
- (UIViewController *)viewController {
    if (_viewController) {
        return _viewController;
    } else {
        return [UIApplication sharedApplication].adv_getCurrentWindow.rootViewController;
    }
}

- (UIImageView *)bgImgV {
    if (!_bgImgV) {
        _bgImgV = [[UIImageView alloc] initWithImage:_backgroundImage];
    }
    _bgImgV.frame = [UIScreen mainScreen].bounds;
    _bgImgV.userInteractionEnabled = YES;
    return _bgImgV;
}

- (NSMutableArray *)arrParallelSupplier {
    if (!_arrParallelSupplier) {
        _arrParallelSupplier = [NSMutableArray array];
    }
    return _arrParallelSupplier;
}
@end
