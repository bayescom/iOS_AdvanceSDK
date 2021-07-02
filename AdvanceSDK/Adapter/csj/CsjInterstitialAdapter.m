//
//  CsjInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjInterstitialAdapter.h"

#if __has_include(<BUAdSDK/BUNativeExpressInterstitialAd.h>)
#import <BUAdSDK/BUNativeExpressInterstitialAd.h>
#else
#import "BUNativeExpressInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface CsjInterstitialAdapter () <BUNativeExpresInterstitialAdDelegate>
@property (nonatomic, strong) BUNativeExpressInterstitialAd *csj_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation CsjInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _csj_ad = [[BUNativeExpressInterstitialAd alloc] initWithSlotID:_supplier.adspotid adSize:CGSizeMake(300, 450)];
    }
    return self;
}

- (void)deallocAdapter {
    
}

- (void)loadAd {
    _csj_ad.delegate = self;
    NSLog(@"加载穿山甲 supplier: %@ -- %ld", _supplier, (long)_supplier.priority);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"穿山甲 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"穿山甲 失败");
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"穿山甲 正在加载中");
    } else {
        ADVLog(@"穿山甲 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [self.csj_ad loadAdData];
    }
}

- (void)showAd {
    [_csj_ad showAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// MARK: ======================= BUNativeExpresInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)nativeExpresInterstitialAdDidLoad:(BUNativeExpressInterstitialAd *)interstitialAd {
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)nativeExpresInterstitialAd:(BUNativeExpressInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }

    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceInterstitialOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 插屏广告渲染失败
- (void)nativeExpresInterstitialAdRenderFail:(BUNativeExpressInterstitialAd *)interstitialAd error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _csj_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdRenderFailed)]) {
//        [self.delegate advanceInterstitialOnAdRenderFailed];
//    }
}


/// 插屏广告曝光回调
- (void)nativeExpresInterstitialAdWillVisible:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 插屏广告点击回调
- (void)nativeExpresInterstitialAdDidClick:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)nativeExpresInterstitialAdDidClose:(BUNativeExpressInterstitialAd *)interstitialAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/// 广告可以调用Show
- (void)nativeExpresInterstitialAdRenderSuccess:(BUNativeExpressInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    NSLog(@"穿山甲插屏视频拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

@end
