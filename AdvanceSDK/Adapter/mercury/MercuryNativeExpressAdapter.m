//
//  MercuryNativeExpressAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryNativeExpressAdapter.h"
#if __has_include(<MercurySDK/MercuryNativeExpressAd.h>)
#import <MercurySDK/MercuryNativeExpressAd.h>
#else
#import "MercuryNativeExpressAd.h"
#endif
#import "AdvanceNativeExpress.h"

@interface MercuryNativeExpressAdapter () <MercuryNativeExpressAdDelegete>
@property (nonatomic, strong) MercuryNativeExpressAd *mercury_ad;
@property (nonatomic, strong) NSDictionary *params;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;

@end

@implementation MercuryNativeExpressAdapter

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
    
    _mercury_ad = [[MercuryNativeExpressAd alloc] initAdWithAdspotId:_adspot.currentSdkSupplier.adspotid];
    _mercury_ad.delegate = self;
    _mercury_ad.videoMuted = YES;
    _mercury_ad.videoPlayPolicy = MercuryVideoAutoPlayPolicyWIFI;
    _mercury_ad.renderSize = _adspot.adSize;
    [_mercury_ad loadAdWithCount:adCount];
}

- (void)dealloc {
    NSLog(@"%s", __func__);
}

// MARK: ======================= MercuryNativeExpressAdDelegete =======================
/// 拉取原生模板广告成功 | (注意: nativeExpressAdView在此方法执行结束不被强引用，nativeExpressAd中的对象会被自动释放)
- (void)mercury_nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(NSArray<UIView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
        if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
            [self.delegate advanceNativeExpressOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id
                                                                 error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg": @"无广告返回"}]];
        }
        [self.adspot selectSdkSupplierWithError:nil];
    } else if (self.adspot) {
        for (UIView *view in views) {
            if ([view isKindOfClass:NSClassFromString(@"MercuryNativeExpressAdView")]) {
                ((MercuryNativeExpressAdView *)view).controller = _controller;
            }
        }
        [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
        if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [self.delegate advanceNativeExpressOnAdLoadSuccess:views];
        }
    }
}

/// 拉取原生模板广告失败
- (void)mercury_nativeExpressAdFailToLoadWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceNativeExpressOnAdFailedWithSdkId:_adspot.currentSdkSupplier.id error:error];
    }
    [self.adspot selectSdkSupplierWithError:error];
}

/// 原生模板广告渲染成功, 此时的 nativeExpressAdView.size.height 根据 size.width 完成了动态更新。
- (void)mercury_nativeExpressAdViewRenderSuccess:(MercuryNativeExpressAdView *)nativeExpressAdView {
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [self.delegate advanceNativeExpressOnAdRenderSuccess:nativeExpressAdView];
    }
}

/// 原生模板广告渲染失败
- (void)mercury_nativeExpressAdViewRenderFail:(MercuryNativeExpressAdView *)nativeExpressAdView {
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
        [self.delegate advanceNativeExpressOnAdRenderFail:nativeExpressAdView];
    }
}

/// 原生模板广告曝光回调
- (void)mercury_nativeExpressAdViewExposure:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
        [self.delegate advanceNativeExpressOnAdShow:nativeExpressAdView];
    }
}

/// 原生模板广告点击回调
- (void)mercury_nativeExpressAdViewClicked:(MercuryNativeExpressAdView *)nativeExpressAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
        [self.delegate advanceNativeExpressOnAdClicked:nativeExpressAdView];
    }
}

/// 原生模板广告被关闭
- (void)mercury_nativeExpressAdViewClosed:(MercuryNativeExpressAdView *)nativeExpressAdView {
    if ([self.delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
        [self.delegate advanceNativeExpressOnAdClosed:nativeExpressAdView];
    }
}

@end
