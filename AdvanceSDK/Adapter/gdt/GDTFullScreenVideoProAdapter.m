//
//  GDTFullScreenVideoProAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/29.
//

#import "GDTFullScreenVideoProAdapter.h"

#if __has_include(<GDTExpressInterstitialAd.h>)
#import <GDTExpressInterstitialAd.h>
#else
#import "GDTExpressInterstitialAd.h"
#endif

#import "AdvanceFullScreenVideo.h"
#import "AdvLog.h"

@interface GDTFullScreenVideoProAdapter ()<GDTExpressInterstitialAdDelegate>
@property (nonatomic, strong) GDTExpressInterstitialAd *gdt_ad;
@property (nonatomic, weak) AdvanceFullScreenVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation GDTFullScreenVideoProAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTExpressInterstitialAd alloc] initWithPlacementId:_supplier.adspotid];
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载广点通 supplier: %@", _supplier);
    _gdt_ad.delegate = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_gdt_ad loadFullScreenAd];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"广点通加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"广点通 成功");
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"广点通 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)deallocAdapter {
    
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    [_gdt_ad presentFullScreenAdFromRootViewController:_adspot.viewController];
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
//    NSLog(@"广点通插屏拉取成功 %@",self.gdt_ad);
    if (_supplier.isParallel == YES) {
//        NSLog(@"修改状态: %@", _supplier);
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
    if (status == GDTMediaPlayerStatusStoped) {
        if ([self.delegate respondsToSelector:@selector(advanceFullScreenVideoOnAdPlayFinish)]) {
            [self.delegate advanceFullScreenVideoOnAdPlayFinish];
        }
    }
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
