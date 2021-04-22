//
//  MercuryInterstitialAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryInterstitialAdapter.h"
#if __has_include(<MercurySDK/MercuryInterstitialAd.h>)
#import <MercurySDK/MercuryInterstitialAd.h>
#else
#import "MercuryInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface MercuryInterstitialAdapter () <MercuryInterstitialAdDelegate>
@property (nonatomic, strong) MercuryInterstitialAd *mercury_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation MercuryInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercuryInterstitialAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];

    }
    return self;
}

- (void)deallocAdapter {
    
}


- (void)loadAd {
    ADVLog(@"加载Mercury supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"Mercury 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"Mercury 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"Mercury 正在加载中");
    } else {
        ADVLog(@"Mercury load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_mercury_ad loadAd];
    }

}

- (void)showAd {
    [_mercury_ad presentAdFromViewController:_adspot.viewController];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= MercuryInterstitialAdDelegate =======================
/// 插屏广告预加载成功回调，当接收服务器返回的广告数据成功且预加载后调用该函数
- (void)mercury_interstitialSuccess  {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

/// 插屏广告预加载失败回调，当接收服务器返回的广告数据失败后调用该函数
- (void)mercury_interstitialFailError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
    _mercury_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceInterstitialOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

/// 插屏广告视图曝光失败回调，插屏广告曝光失败回调该函数
- (void)mercury_interstitialFailToPresent {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"广告素材渲染失败" code:301 userInfo:@{@"msg": @"广告素材渲染失败"}]];
    _mercury_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceInterstitialOnAdRenderFailed)]) {
//        [self.delegate advanceInterstitialOnAdRenderFailed];
//    }
    
}

/// 插屏广告曝光回调
- (void)mercury_interstitialWillExposure {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/// 插屏广告点击回调
- (void)mercury_interstitialClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/// 插屏广告曝光结束回调，插屏广告曝光结束回调该函数
- (void)mercury_interstitialDidDismissScreen {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

@end
