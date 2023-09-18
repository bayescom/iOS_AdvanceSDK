//
//  AdvanceSplash.m
//  Demo
//
//  Created by CherryKing on 2020/11/19.
//

#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvanceSplash.h"
#import "AdvPolicyServiceDelegate.h"
#import "AdvPolicyModel.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import "AdvSupplierLoader.h"

@interface AdvanceSplash ()

@property (nonatomic, strong) NSNumber *isGMBidding;

@end

@implementation AdvanceSplash

- (instancetype)initWithAdspotId:(NSString *)adspotid
                       customExt:(nullable NSDictionary *)ext
                  viewController:(nullable UIViewController *)viewController {
    ADV_LEVEL_INFO_LOG(@"==================== 初始化开屏广告, id: %@====================", adspotid);
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
        [_delegate didFailLoadingADSourceWithSpotId:self.adspotid error:error description:nil];
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
    /// 获取竞胜的adpater
    self.targetAdapter = [self.adapterMap objectForKey:supplier.supplierKey];
    /// 通知adpater竞胜，该给予外部回调了
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void (*)(id, SEL))objc_msgSend)((id)self.targetAdapter, @selector(winnerAdapterToShowAd));
    
    if ([_delegate respondsToSelector:@selector(didFinishBiddingADWithSpotId:price:)]) {
        [_delegate didFinishBiddingADWithSpotId:self.adspotid price:supplier.sdk_price];
    }
}

/// 加载某一个渠道对象
- (void)advPolicyServiceLoadAnySupplier:(nullable AdvSupplier *)supplier {
    // 加载渠道SDK进行初始化调用
    [AdvSupplierLoader loadSupplier:supplier];
    
    // 通知外部该渠道开始加载广告
    if ([self.delegate respondsToSelector:@selector(didStartLoadingADSourceWithSpotId:sourceId:)]) {
        [self.delegate didStartLoadingADSourceWithSpotId:self.adspotid sourceId:supplier.identifier];
    }
    
    // 根据渠道id初始化对应Adapter
    NSString *clsName = [self mappingClassNameWithSupplierId:supplier.identifier];
#pragma clang diagnostic ignored "-Wundeclared-selector"
    id adapter = ((id (*)(id, SEL, id, id))objc_msgSend)((id)[NSClassFromString(clsName) alloc], @selector(initWithSupplier:adspot:), supplier, self);
    ((void (*)(id, SEL, id))objc_msgSend)((id)adapter, @selector(setDelegate:), _delegate);
    ((void (*)(id, SEL))objc_msgSend)((id)adapter, @selector(loadAd));
    if (adapter) {
        [self.adapterMap setObject:adapter forKey:supplier.supplierKey];
    }
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
    } else if ([supplierId isEqualToString:SDK_ID_BIDDING]) {
        clsName = @"AdvBiddingSplashAdapter";
    }
    return clsName;
}


- (void)loadAd {
    [super loadAd];
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


- (void)gmShowAd {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    ((void (*)(id, SEL))objc_msgSend)((id)self.targetAdapter, @selector(gmShowAd));
    
    
#pragma clang diagnostic pop
    
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

@end
