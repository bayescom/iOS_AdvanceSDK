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
#import "AdvSupplierLoader.h"

@interface AdvanceBanner ()

@property (nonatomic, strong) id adapter;

@end

@implementation AdvanceBanner

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                  viewController:(UIViewController *)viewController {
    return [self initWithAdspotId:adspotid adContainer:adContainer customExt:nil viewController:viewController];
}

- (instancetype)initWithAdspotId:(NSString *)adspotid
                     adContainer:(UIView *)adContainer
                       customExt:(nullable NSDictionary *)ext
                  viewController:(UIViewController *)viewController {
    
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:ext];
    [extra setValue:AdvSdkTypeAdNameBanner forKey: AdvSdkTypeAdName];
    
    if (self = [super initWithMediaId:[AdvSdkConfig shareInstance].appId adspotId:adspotid customExt:extra]) {
        self.adContainer = adContainer;
        self.viewController = viewController;
        self.refreshInterval = MAXINTERP;
        self.muted = YES;
    }
    return self;
}


// MARK: ======================= AdvanceSupplierDelegate =======================
/// 加载策略Model成功
- (void)advPolicyServiceLoadSuccessWithModel:(nonnull AdvSupplierModel *)model {
    if ([_delegate respondsToSelector:@selector(didFinishLoadingADPolicyWithSpotId:)]) {
        [_delegate didFinishLoadingADPolicyWithSpotId:self.adspotid];
    }
}

/// 加载策略Model失败
- (void)advPolicyServiceLoadFailedWithError:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:error description:[self.errorDescriptions copy]];
    }
}

/// 返回下一个渠道的参数
- (void)advPolicyServiceLoadSupplier:(nullable AdvSupplier *)supplier error:(nullable NSError *)error {
    
    // 加载渠道SDK进行初始化调用
    [[AdvSupplierLoader defaultInstance] loadSupplier:supplier extra:self.ext];
    
    // 返回渠道有问题 则不用再执行下面的渠道了
    if (error) {
        // 错误回调只调用一次
        if ([_delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
            [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:error description:[self.errorDescriptions copy]];
        }
        return;
    }
    
    // 开始加载渠道前通知调用者
    if ([self.delegate respondsToSelector:@selector(didStartLoadingADSourceWithSpotId:sourceId:)]) {
        [self.delegate didStartLoadingADSourceWithSpotId:self.adspotid sourceId:supplier.identifier];
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
        NSString *msg = [NSString stringWithFormat:@"%@ 不存在", clsName];
        //        ADVLog(@"%@", msg);
        [self loadNextSupplierIfHas];
    }
}

- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    dispatch_async(dispatch_get_main_queue(), ^{
       // UI更新代码
        ((void (*)(id, SEL))objc_msgSend)((id)_adapter, @selector(showAd));
    });
#pragma clang diagnostic pop
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}
@end
