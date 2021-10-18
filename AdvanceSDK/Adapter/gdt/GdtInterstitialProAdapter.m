//
//  GdtInterstitialProAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/28.
//

#import "GdtInterstitialProAdapter.h"

#if __has_include(<GDTExpressInterstitialAd.h>)
#import <GDTExpressInterstitialAd.h>
#else
#import "GDTExpressInterstitialAd.h"
#endif

#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface GdtInterstitialProAdapter ()<GDTExpressInterstitialAdDelegate>
@property (nonatomic, strong) GDTExpressInterstitialAd *gdt_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GdtInterstitialProAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceInterstitial *)adspot {
    if (self = [super init]) {
        _adspot = (AdvanceInterstitial *)adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTExpressInterstitialAd alloc] initWithPlacementId:_supplier.adspotid];
    }
    return self;
}

- (void)deallocAdapter {
    
}


- (void)loadAd {
    _gdt_ad.delegate = self;
//    ADVLog(@"加载观点通 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
//        ADVLog(@"广点通 成功");
        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
            [self.delegate advanceUnifiedViewDidLoad];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
//        ADVLog(@"广点通 失败 %@", _supplier);
        _gdt_ad = nil;
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
//        ADVLog(@"广点通 正在加载中");
    } else {
//        ADVLog(@"广点通 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_gdt_ad loadHalfScreenAd];
    }
}

- (void)showAd {
    [_gdt_ad presentHalfScreenAdFromRootViewController:_adspot.viewController];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


/**
 *  模板插屏广告预加载成功回调
 *  当接收服务器返回的广告数据成功且预加载后调用该函数
 */
- (void)expressInterstitialSuccessToLoadAd:(GDTExpressInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    NSLog(@"广点通插屏拉取成功 %@",self.gdt_ad);
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    
}

/**
 *  模板插屏广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)expressInterstitialFailToLoadAd:(GDTExpressInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
    _gdt_ad = nil;
}

/**
 *  模板插屏广告将要展示回调
 *  模板插屏广告即将展示回调该函数
 */
- (void)expressInterstitialWillPresentScreen:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 *  模板插屏广告视图展示成功回调
 *  模板插屏广告展示成功回调该函数
 */
- (void)expressInterstitialDidPresentScreen:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 *  模板插屏广告视图展示失败回调
 *  模板插屏广告展示失败回调该函数
 */
- (void)expressInterstitialFailToPresent:(GDTExpressInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    
}

/**
 *  模板插屏广告展示结束回调
 *  模板插屏广告展示结束回调该函数
 */
- (void)expressInterstitialDidDismissScreen:(GDTExpressInterstitialAd *)unifiedInterstitial {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

/**
 *  当点击下载应用时会调用系统程序打开其它App或者Appstore时回调
 */
- (void)expressInterstitialWillLeaveApplication:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 *  模板插屏广告曝光回调
 */
- (void)expressInterstitialWillExposure:(GDTExpressInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/**
 *  模板插屏广告点击回调
 */
- (void)expressInterstitialClicked:(GDTExpressInterstitialAd *)unifiedInterstitial {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/**
 *  点击模板插屏广告以后即将弹出全屏广告页
 */
- (void)expressInterstitialAdWillPresentFullScreenModal:(GDTExpressInterstitialAd *)unifiedInterstitial {
}

/**
 *  点击模板插屏广告以后弹出全屏广告页
 */
- (void)expressInterstitialAdDidPresentFullScreenModal:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 *  模板全屏广告页将要关闭
 */
- (void)expressInterstitialAdWillDismissFullScreenModal:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 *  模板全屏广告页被关闭
 */
- (void)expressInterstitialAdDidDismissFullScreenModal:(GDTExpressInterstitialAd *)unifiedInterstitial {

}

/**
 * 模板插屏视频广告 player 播放状态更新回调
 */
- (void)expressInterstitialAd:(GDTExpressInterstitialAd *)unifiedInterstitial playerStatusChanged:(GDTMediaPlayerStatus)status {
    
}

/**
 * 模板插屏视频广告详情页 WillPresent 回调
 */
- (void)expressInterstitialAdViewWillPresentVideoVC:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 * 模板插屏视频广告详情页 DidPresent 回调
 */
- (void)expressInterstitialAdViewDidPresentVideoVC:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 * 模板插屏视频广告详情页 WillDismiss 回调
 */
- (void)expressInterstitialAdViewWillDismissVideoVC:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}

/**
 * 模板插屏视频广告详情页 DidDismiss 回调
 */
- (void)expressInterstitialAdViewDidDismissVideoVC:(GDTExpressInterstitialAd *)unifiedInterstitial {
    
}


@end
