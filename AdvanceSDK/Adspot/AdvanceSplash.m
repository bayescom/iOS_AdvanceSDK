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

@end

@implementation AdvanceSplash

- (instancetype)initWithAdspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController {
    if (self = [super initWithMediaId:nil adspotId:adspotid]) {
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
    [_timeoutCheckTimer invalidate];

    _timeoutCheckTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeoutCheckTimerAction)];
    [_timeoutCheckTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    
    [super loadAd];
}

- (void)reportWithType:(AdvanceSdkSupplierRepoType)repoType {
    [super reportWithType:repoType];
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
    if([_delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
        [_delegate advanceOnAdNotFilled:[AdvError errorWithCode:AdvErrorCode_115].toNSError];
        [_adapter performSelector:@selector(deallocAdapter)];
    }
    _delegate = nil;
}

- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
        [self deallocSelf];
        [_timeoutCheckTimer invalidate];
        _timeoutCheckTimer = nil;
    }
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
    [self deallocSelf];
}

/// 返回下一个渠道的参数
- (void)advanceBaseAdapterLoadSuppluer:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        ADVLog(@"%@", error);
        [self deallocSelf];
        return;
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
        [self deallocSelf];
    } else {
        supplier.timeout = (_timeout_stamp - now) >= 5000 ? 5000 : (_timeout_stamp - now);
        if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [_adapter performSelector:@selector(deallocAdapter)];
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
}

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

@end
