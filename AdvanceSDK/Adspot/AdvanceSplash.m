//
//  AdvanceSplash.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/7.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "AdvanceSplash.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "UIApplication+Advance.h"

@interface AdvanceSplash () <AdvanceBaseAdspotDelegate>
@property (nonatomic, strong) id adapter;

@property (nonatomic, strong) UIImageView *bgImgV;

@property (nonatomic, assign) NSInteger timeout_stamp;
@property (nonatomic, strong) CADisplayLink *timeoutCheckTimer;


@end

@implementation AdvanceSplash

-  (instancetype)initWithMediaId:(NSString *)mediaid
                        adspotId:(NSString *)adspotid
                  viewController:(UIViewController *)viewController {
    if (self = [super initWithAdspotId:adspotid]) {
        self.supplierDelegate = self;
        self.viewController = viewController;
    }
    return self;
}
-  (instancetype)initWithAdspotId:(NSString *)adspotid
                   viewController:(UIViewController *)viewController {
    if (self = [super initWithAdspotId:adspotid]) {
        self.supplierDelegate = self;
        self.viewController = viewController;
    }
    return self;
}

- (void)deallocSelf {
    [_bgImgV removeFromSuperview];
    if([self.delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
        [self.delegate advanceOnAdNotFilled:[NSError errorWithDomain:@"com.AdvanceSDK.error" code:10601 userInfo:@{@"msg": @"请求超出设定总时长"}]];
        [_adapter performSelector:@selector(deallocAdapter)];
        self.delegate = nil;
    }
}

- (void)timeoutCheckTimerAction {
    if ([[NSDate date] timeIntervalSince1970]*1000 > _timeout_stamp) {
        [self deallocSelf];
        [_timeoutCheckTimer invalidate];
        _timeoutCheckTimer = nil;
    }
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

// MARK: ======================= AdvanceBaseAdspotDelegate =======================
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkId 渠道ID
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkId:(NSString *)sdkId params:(NSDictionary *)params {
    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([sdkId isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtSplashAdapter";
    } else if ([sdkId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjSplashAdapter";
    } else if ([sdkId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercurySplashAdapter";
    }

    // 请求超时了
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970]*1000;
    if (now+500 > _timeout_stamp) {
        [self deallocSelf];
    } else {
        self.currentSdkSupplier.timeout = (_timeout_stamp - now) >= 5000 ? 5000 : (_timeout_stamp - now);
        if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
            [_adapter performSelector:@selector(deallocAdapter)];
            _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithParams:adspot:), params, self);
            ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
            ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
            if (_adapter && _backgroundImage) {
                [[UIApplication sharedApplication].by_getCurrentWindow addSubview:self.bgImgV];
            }
        } else {
            NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
            if([self.delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
                [self.delegate advanceOnAdNotFilled:[NSError errorWithDomain:@"com.AdvanceSDK.error" code:10600 userInfo:@{@"msg": msg}]];
            }
        }
    }
}

/// 策略请求失败
/// @param error 失败原因
- (void)advanceBaseAdspotFailedWithError:(NSError *)error {
    [_bgImgV removeFromSuperview];
    if([self.delegate respondsToSelector:@selector(advanceOnAdNotFilled:)]) {
        [self.delegate advanceOnAdNotFilled:error];
    }
}

- (void)loadAd {
    if (_timeout <= 0) { _timeout = 60; }
    // 记录过期的时间
    _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + _timeout)*1000;
    // 开启定时器监听过期
    [_timeoutCheckTimer invalidate];

    _timeoutCheckTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(timeoutCheckTimerAction)];
    [_timeoutCheckTimer addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];

    [super loadAd];
    if (_adapter && _backgroundImage) {
        [[UIApplication sharedApplication].by_getCurrentWindow addSubview:self.bgImgV];
    }
}

// MARK: ======================= get =======================
- (UIViewController *)viewController {
    if (_viewController) {
        return _viewController;
    } else {
        return [UIApplication sharedApplication].by_getCurrentWindow.rootViewController;
    }
}

- (UIImageView *)bgImgV {
    if (!_bgImgV) {
        _bgImgV = [[UIImageView alloc] initWithImage:_backgroundImage];
    }
    _bgImgV.frame = [UIScreen mainScreen].bounds;
    _bgImgV.image = _backgroundImage;
    return _bgImgV;
}

@end
