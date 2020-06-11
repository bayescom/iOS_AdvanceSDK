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

@interface AdvanceInterstitial () <AdvanceBaseAdspotDelegate>
@property (nonatomic, strong) id adapter;

@property (nonatomic, assign) CGRect frame;
@property (nonatomic, strong) UIViewController *controller;

@end

@implementation AdvanceInterstitial
- (instancetype)initWithMediaId:(NSString *)mediaid adspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController {
    if (self = [super initWithAdspotId:adspotid]) {
        self.supplierDelegate = self;
        _viewController = viewController;
    }
    return self;
}
- (instancetype)initWithAdspotId:(NSString *)adspotid viewController:(nonnull UIViewController *)viewController {
    if (self = [super initWithAdspotId:adspotid]) {
        self.supplierDelegate = self;
        _viewController = viewController;
    }
    return self;
}

// MARK: ======================= AdvanceBaseAdspotDelegate =======================
/// 加载渠道广告，将会返回渠道所需参数
/// @param sdkId 渠道ID
/// @param params 渠道参数
- (void)advanceBaseAdspotWithSdkId:(NSString *)sdkId params:(NSDictionary *)params {
    // 根据渠道id自定义初始化
    NSString *clsName = @"";
    if ([sdkId isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtInterstitialAdapter";
    } else if ([sdkId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjInterstitialAdapter";
    } else if ([sdkId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercuryInterstitialAdapter";
    }
    if (NSClassFromString(clsName)) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        _adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithParams:adspot:), params, self);
        ((void (*)(id, SEL, id))objc_msgSend)((id)_adapter, @selector(setDelegate:), _delegate);
        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(loadAd));
#pragma clang diagnostic pop
    } else {
        NSLog(@"%@ 不存在", clsName);
    }
}

- (void)showAd {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(showAd));
#pragma clang diagnostic pop
}

/// 策略请求失败
/// @param error 失败原因
- (void)advanceBaseAdspotFailedWithError:(NSError *)error {
    NSLog(@"%@", error);
    if([self.delegate respondsToSelector:@selector(advanceOnAdNotFilled:)])
    {
        [self.delegate advanceOnAdNotFilled:error];
    }
}

@end
