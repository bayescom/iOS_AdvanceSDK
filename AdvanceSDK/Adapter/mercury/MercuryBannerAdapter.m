//
//  MercuryBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "MercuryBannerAdapter.h"

#if __has_include(<MercurySDK/MercuryBannerAdView.h>)
#import <MercurySDK/MercuryBannerAdView.h>
#else
#import "MercuryBannerAdView.h"
#endif

#import "AdvanceBanner.h"
#import "AdvLog.h"

@interface MercuryBannerAdapter () <MercuryBannerAdViewDelegate>
@property (nonatomic, strong) MercuryBannerAdView *mercury_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@property (nonatomic, assign) BOOL isBided;
@property (nonatomic, assign) BOOL isDidload;
@property (nonatomic, assign) BOOL isClose;

@end

@implementation MercuryBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _mercury_ad = [[MercuryBannerAdView alloc] initWithFrame:rect adspotId:_adspot.adspotid delegate:self];
        _mercury_ad.controller = _adspot.viewController;
        _mercury_ad.animationOn = YES;
        _mercury_ad.showCloseBtn = YES;
        _mercury_ad.interval = _adspot.refreshInterval;

    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Mercury supplier: %@", _supplier);
        
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_mercury_ad loadAdAndShow];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Mercury加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Mercury 成功");
    if (_isDidload) {
        return;
    }
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"Mercury 失败");
    [_adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self.mercury_ad);
    
    if (_mercury_ad) {
        //        NSLog(@"Mercury 释放了");
        [_mercury_ad removeFromSuperview];
        _mercury_ad.delegate = nil;
        _mercury_ad = nil;
        [_adspot.adContainer removeFromSuperview];
    }
}
    
- (void)showAd {
    if (_mercury_ad) {
        [_adspot.adContainer addSubview:_mercury_ad];
    } else {
        [self deallocAdapter];
    }

}

// MARK: ======================= MercuryBannerAdViewDelegate =======================
// 广告数据拉取成功回调
- (void)mercury_bannerViewDidReceived:(MercuryBannerAdView *)banner {
    NSLog(@"%s", __func__);
    _supplier.supplierPrice = banner.price;
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (!_isBided) {// 只让bidding触发一次即可
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        _isBided = YES;
    }
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];
    _isDidload = YES;

}

/// 请求广告条数据失败后调用
- (void)mercury_bannerViewFailToReceived:(MercuryBannerAdView *_Nonnull)banner error:(nullable NSError *)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed  supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
//    NSLog(@"========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
//    if ([self.delegate respondsToSelector:@selector(advanceBannerOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceBannerOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

// 曝光回调
- (void)mercury_bannerViewWillExposure:(MercuryBannerAdView *)banner {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

// 点击回调
- (void)mercury_bannerViewClicked:(MercuryBannerAdView *)banner {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

// 关闭回调
- (void)mercury_bannerViewWillClose:(MercuryBannerAdView *)banner {
    [_mercury_ad removeFromSuperview];
    _mercury_ad = nil;
    if ([self.delegate respondsToSelector:@selector(bannerView:didCloseAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didCloseAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
        
    }
}

- (void)unifiedDelegate {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingBannerADWithSpotId:)]) {
        [self.delegate didFinishLoadingBannerADWithSpotId:self.adspot.adspotid];
    }
    //    [self showAd];
}

//- (void)closeDelegate {
//    if (_isClose) {
//        return;
//    }
//    _isClose = YES;
//    
//    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
//        [self.delegate advanceDidClose];
//        
//    }
//    [self deallocAdapter];
//    
//}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s",__func__);
}



@end
