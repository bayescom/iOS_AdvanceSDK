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
#import "AdvLog.h"

@interface GdtNativeExpressAdapter () <GDTNativeExpressAdDelegete>
@property (nonatomic, strong) GDTNativeExpressAd *gdt_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray<__kindof GDTNativeExpressAdView *> *views;
@end

@implementation GdtNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTNativeExpressAd alloc] initWithPlacementId:_supplier.adspotid
                                                           adSize:_adspot.adSize];

    }
    return self;
}

- (void)loadAd {
    int adCount = 1;
    
    _gdt_ad.delegate = self;
    ADVLog(@"加载广点通 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"广点通 成功");
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"广点通 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"广点通 正在加载中");
    } else {
        ADVLog(@"广点通 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_gdt_ad loadAd:adCount];;
    }

}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= GDTNativeExpressAdDelegete =======================
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateFailed;
            return;
        }

//        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//            [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
//        }
    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        for (GDTNativeExpressAdView *view in views) {
            view.controller = _adspot.viewController;
        }
        
        if (_supplier.isParallel == YES) {
            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            self.views = views;
            return;
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
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

    _gdt_ad = nil;
}

/**
 * 渲染原生模板广告失败
 */
- (void)nativeExpressAdViewRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
        [_delegate advanceNativeExpressOnAdRenderFail:nativeExpressAdView];
    }
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:10000 userInfo:@{@"msg": @"渲染原生模板广告失败"}]];
//    }
    _gdt_ad = nil;
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [_delegate advanceNativeExpressOnAdRenderSuccess:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
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
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
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
