//
//  GdtNativeExpressAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtNativeExpressAdapter.h"

#if __has_include(<GDTNativeExpressAd.h>)
#import <GDTNativeExpressAd.h>
#else
#import "GDTNativeExpressAd.h"
#endif
#if __has_include(<GDTNativeExpressAdView.h>)
#import <GDTNativeExpressAdView.h>
#else
#import "GDTNativeExpressAdView.h"
#endif

#import "AdvanceNativeExpress.h"

@interface GdtNativeExpressAdapter () <GDTNativeExpressAdDelegete>
@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;

@end

@implementation GdtNativeExpressAdapter

- (instancetype)initWithParams:(NSDictionary *)params
                        adspot:(AdvanceNativeExpress *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _params = params;
    }
    return self;
}

- (void)loadAd {
    int adCount = 1;
    if (_adspot && _adspot.currentSdkSupplier.adCount > 0) {
        adCount = _adspot.currentSdkSupplier.adCount;
    }
    
    _gdt_ad = [[GDTNativeExpressAd alloc] initWithPlacementId:_adspot.currentSdkSupplier.adspotid
                                                       adSize:_adspot.adSize];
    _gdt_ad.delegate = self;
    [_gdt_ad loadAd:adCount];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= GDTNativeExpressAdDelegete =======================
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
            [_delegate advanceNativeExpressOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        }
        [self.adspot selectSdkSupplierWithError:nil];
    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
        for (GDTNativeExpressAdView *view in views) {
            view.controller = _adspot.viewController;
        }
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:views];
        }
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    _gdt_ad = nil;
    [_adspot selectSdkSupplierWithError:error];
}

/**
 * 渲染原生模板广告失败
 */
- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:[NSError errorWithDomain:@"" code:10000 userInfo:@{@"msg": @"渲染原生模板广告失败"}]];
    }
    _gdt_ad = nil;
    [_adspot selectSdkSupplierWithError:[NSError errorWithDomain:@"" code:10000 userInfo:@{@"msg": @"渲染原生模板广告失败"}]];
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [_delegate advanceNativeExpressOnAdRenderSuccess:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
        [_delegate advanceNativeExpressOnAdClicked:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
        [_delegate advanceNativeExpressOnAdClosed:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
        [_delegate advanceNativeExpressOnAdShow:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewWillPresentScreen:(UIView *)nativeExpressAdView {
}

- (void)nativeExpressAdViewDidPresentScreen:(UIView *)nativeExpressAdView {
}

- (void)nativeExpressAdViewWillDissmissScreen:(UIView *)nativeExpressAdView {
}

- (void)nativeExpressAdViewDidDissmissScreen:(UIView *)nativeExpressAdView {
}

@end
