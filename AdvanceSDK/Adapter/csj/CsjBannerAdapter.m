//
//  CsjBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjBannerAdapter.h"

#if __has_include(<BUAdSDK/BUNativeExpressBannerView.h>)
#import <BUAdSDK/BUNativeExpressBannerView.h>
#else
#import "BUNativeExpressBannerView.h"
#endif
#import "AdvLog.h"
#import "AdvanceBanner.h"

@interface CsjBannerAdapter () <BUNativeExpressBannerViewDelegate>
@property (nonatomic, strong) BUNativeExpressBannerView *csj_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@property (nonatomic, assign) BOOL isBided;
@property (nonatomic, assign) BOOL isDidload;
@property (nonatomic, assign) BOOL isClose;

@end

@implementation CsjBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _csj_ad = [[BUNativeExpressBannerView alloc] initWithSlotID:_supplier.adspotid rootViewController:_adspot.viewController adSize:_adspot.adContainer.bounds.size interval:_adspot.refreshInterval];
        _csj_ad.frame = _adspot.adContainer.bounds;
        _csj_ad.delegate = self;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
        
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_csj_ad loadAdData];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    if (_isDidload) {
        return;
    }
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [_adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self.csj_ad);
    
    if (_csj_ad) {
        //        NSLog(@"穿山甲 释放了");
        [_csj_ad removeFromSuperview];
        _csj_ad.delegate = nil;
        _csj_ad = nil;
        [_adspot.adContainer removeFromSuperview];
    }
}
    
- (void)showAd {
    if (_csj_ad) {
        [_adspot.adContainer addSubview:_csj_ad];
    } else {
        [self deallocAdapter];
    }

}

// MARK: ======================= BUNativeExpressBannerViewDelegate =======================
/**
 *  广告数据拉取成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)nativeExpressBannerAdViewDidLoad:(BUNativeExpressBannerView *)bannerAdView {
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (!_isBided) {// 只让bidding触发一次即可
        [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        _isBided = YES;
    }
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];
    _isDidload = YES;
}

- (void)nativeExpressBannerAdViewRenderSuccess:(BUNativeExpressBannerView *)bannerAdView {
    if (_delegate && [_delegate respondsToSelector:@selector(advanceAdMaterialLoadSuccess)]) {
        [_delegate advanceAdMaterialLoadSuccess];
    }
}

/**
 *  请求广告数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView didLoadFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed  supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
//    NSLog(@"========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }
}

/**
 *  banner2.0曝光回调
 */
- (void)nativeExpressBannerAdViewWillBecomVisible:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)nativeExpressBannerAdViewDidClick:(BUNativeExpressBannerView *)bannerAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)nativeExpressBannerAdView:(BUNativeExpressBannerView *)bannerAdView dislikeWithReason:(NSArray<BUDislikeWords *> *_Nullable)filterwords {
    
    [self closeDelegate];
}

    
    
- (void)unifiedDelegate {
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    //    [self showAd];
}

- (void)closeDelegate {
    if (_isClose) {
        return;
    }
    _isClose = YES;
    
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
        
    }
    [self deallocAdapter];
    
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
}

@end
