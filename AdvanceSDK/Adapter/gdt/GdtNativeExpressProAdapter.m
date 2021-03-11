//
//  GdtNativeExpressProAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/3/5.
//

#import "GdtNativeExpressProAdapter.h"
#if __has_include(<GDTNativeExpressProAdManager.h>)
#import <GDTNativeExpressProAdManager.h>
#else
#import "GDTNativeExpressProAdManager.h"
#endif

#if __has_include(<GDTNativeExpressProAdView.h>)
#import <GDTNativeExpressProAdView.h>
#else
#import "GDTNativeExpressProAdView.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"

@interface GdtNativeExpressProAdapter ()<GDTNativeExpressProAdManagerDelegate, GDTNativeExpressProAdViewDelegate>
@property (nonatomic, strong) GDTNativeExpressProAdManager *gdt_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;


@end

@implementation GdtNativeExpressProAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
    }
    return self;
}

- (void)loadAd {
    int adCount = 1;
    GDTAdParams *adParams = [[GDTAdParams alloc] init];
    adParams.adSize = _adspot.adSize;
    
    _gdt_ad = [[GDTNativeExpressProAdManager alloc] initWithPlacementId:_supplier.adspotid
                                                                adPrams:adParams];
    
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd:adCount];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= GDTNativeExpressProAdManagerDelegate =======================
/**
 * 拉取广告成功的回调
 */

- (void)gdt_nativeExpressProAdSuccessToLoad:(GDTNativeExpressProAdManager *)adManager views:(NSArray<__kindof GDTNativeExpressProAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
//        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//            [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
//        }
    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        for (GDTNativeExpressProAdView *view in views) {
            view.controller = _adspot.viewController;
            view.delegate = self;
        }
        
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:views];
        }
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)gdt_nativeExpressProAdFailToLoad:(GDTNativeExpressProAdManager *)adManager error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
    _gdt_ad = nil;

}

/**
 * 渲染原生模板广告失败
 */
- (void)gdt_NativeExpressProAdViewRenderFail:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
        [_delegate advanceNativeExpressOnAdRenderFail:nativeExpressProAdView];
    }
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:10000 userInfo:@{@"msg": @"渲染原生模板广告失败"}]];
//    }
    _gdt_ad = nil;
}

- (void)gdt_NativeExpressProAdViewRenderSuccess:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [_delegate advanceNativeExpressOnAdRenderSuccess:nativeExpressProAdView];
    }
}

- (void)gdt_NativeExpressProAdViewClicked:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
        [_delegate advanceNativeExpressOnAdClicked:nativeExpressProAdView];
    }
}

- (void)gdt_NativeExpressProAdViewClosed:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
        [_delegate advanceNativeExpressOnAdClosed:nativeExpressProAdView];
    }
}

- (void)gdt_NativeExpressProAdViewExposure:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
        [_delegate advanceNativeExpressOnAdShow:nativeExpressProAdView];
    }
}

- (void)gdt_NativeExpressProAdViewWillPresentScreen:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    
}

- (void)gdt_NativeExpressProAdViewDidPresentScreen:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    
}

- (void)gdt_NativeExpressProAdViewWillDissmissScreen:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    
}

- (void)gdt_NativeExpressProAdViewDidDissmissScreen:(GDTNativeExpressProAdView *)nativeExpressProAdView {
    
}

@end
