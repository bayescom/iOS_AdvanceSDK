//
//  AdvanceSplash.m
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvanceSplash.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import "AdvSupplierLoader.h"

@implementation AdvanceSplash

- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(nullable UIViewController *)viewController {
    ADVLog(@"==================== 初始化开屏广告, id: %@====================", adspotid);
    NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithDictionary:ext];
    [extra setValue:AdvSdkTypeAdNameSplash forKey: AdvSdkTypeAdName];
    
    if (self = [super initWithMediaId:[AdvSdkConfig shareInstance].appId adspotId:adspotid customExt:extra]) {
        self.viewController = viewController;
        self.muted = YES;
    }
    return self;
}

// MARK: ======================= AdvPolicyServiceDelegate =======================
/// 广告策略加载成功
- (void)advPolicyServiceLoadSuccessWithModel:(nonnull AdvPolicyModel *)model {
    if ([_delegate respondsToSelector:@selector(didFinishLoadingADPolicyWithSpotId:)]) {
        [_delegate didFinishLoadingADPolicyWithSpotId:self.adspotid];
    }
}

/// 广告策略加载失败
- (void)advPolicyServiceLoadFailedWithError:(nullable NSError *)error {
    if ([_delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:error description:[self.manager.errorInfo copy]];
    }
}

// 开始Bidding
- (void)advPolicyServiceStartBiddingWithSuppliers:(NSArray <AdvSupplier *> *_Nullable)suppliers {
    if ([_delegate respondsToSelector:@selector(didStartBiddingADWithSpotId:)]) {
        [_delegate didStartBiddingADWithSpotId:self.adspotid];
    }
}

// Bidding失败（渠道广告全部加载失败）
- (void)advPolicyServiceFailedBiddingWithError:(NSError *)error description:(NSDictionary *)description {
    if ([_delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:error description:description];
    }
    if ([_delegate respondsToSelector:@selector(didFailBiddingADWithSpotId:error:)]) {
        [_delegate didFailBiddingADWithSpotId:self.adspotid error:error];
    }
}

// 结束Bidding
- (void)advPolicyServiceFinishBiddingWithWinSupplier:(AdvSupplier *_Nonnull)supplier {
    if ([_delegate respondsToSelector:@selector(didFinishBiddingADWithSpotId:price:)]) {
        [_delegate didFinishBiddingADWithSpotId:self.adspotid price:supplier.sdk_price];
    }
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 通知adpater竞胜，该给予外部回调了
    ((void (*)(id, SEL))objc_msgSend)((id)self.targetAdapter, NSSelectorFromString(@"winnerAdapterToShowAd"));
}

/// 加载GroMore
- (void)advPolicyServiceLoadGroMoreSDKWithModel:(nullable AdvPolicyModel *)model {
    /// 初始化gromore sdk
    Class clazz = NSClassFromString(@"GroMoreBiddingManager");
    if (!clazz && [_delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:nil description:@{@"error": @"please pod install 'GroMoreBidding'"}];
        return;
    }
    SEL selector = NSSelectorFromString(@"loadGroMoreSDKWithDataObject:");
    if ([clazz.class respondsToSelector:selector]) {
        ((void (*)(id, SEL, id))objc_msgSend)(clazz.class, selector, model);
    }
    
    /// 加载gromore广告位
    id gmSplash = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(@"GroMoreSplashTrigger") alloc], NSSelectorFromString(@"initWithGroMore:adspot:"), model.gro_more, self);
    ((void (*)(id, SEL, id))objc_msgSend)((id)gmSplash, NSSelectorFromString(@"setDelegate:"), self.delegate);
    ((void (*)(id, SEL))objc_msgSend)((id)gmSplash, NSSelectorFromString(@"loadAd"));
    self.targetAdapter = gmSplash;
}

/// 加载某一个渠道对象
- (void)advPolicyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier completion:^{
        
        // 通知外部该渠道开始加载广告
        if ([self.delegate respondsToSelector:@selector(didStartLoadingADSourceWithSpotId:sourceId:)]) {
            [self.delegate didStartLoadingADSourceWithSpotId:self.adspotid sourceId:supplier.identifier];
        }
        
        // 根据渠道id初始化对应Adapter
        NSString *clsName = [self mappingClassNameWithSupplierId:supplier.identifier];
        id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], NSSelectorFromString(@"initWithSupplier:adspot:"), supplier, self);
        ((void (*)(id, SEL, id))objc_msgSend)((id)adapter, NSSelectorFromString(@"setDelegate:"), self.delegate);
        ((void (*)(id, SEL))objc_msgSend)((id)adapter, NSSelectorFromString(@"loadAd"));
        if (adapter) {
            [self.adapterMap setObject:adapter forKey:supplier.supplierKey];
        }
        
    }];
}

- (NSString *)mappingClassNameWithSupplierId:(NSString *)supplierId {
    NSString *clsName = @"";
    if ([supplierId isEqualToString:SDK_ID_GDT]) {
        clsName = @"GdtSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_CSJ]) {
        clsName = @"CsjSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_MERCURY]) {
        clsName = @"MercurySplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_KS]) {
        clsName = @"KsSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_BAIDU]) {
        clsName = @"BdSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_TANX]) {
        clsName = @"TanxSplashAdapter";
    } else if ([supplierId isEqualToString:SDK_ID_Sigmob]) {
        clsName = @"SigmobSplashAdapter";
    }
    return clsName;
}


- (void)loadAd {
    [super loadAdPolicy];
}

- (void)showInWindow:(UIWindow *)window {
    if (!window) {
        window = [UIApplication sharedApplication].adv_getCurrentWindow;
    }
    if (!self.viewController) {
        self.viewController = window.rootViewController;
    }
    ((void (*)(id, SEL, id))objc_msgSend)((id)self.targetAdapter, NSSelectorFromString(@"showInWindow:"), window);
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

@end
