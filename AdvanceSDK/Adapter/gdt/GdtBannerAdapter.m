//
//  GdtBannerAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "GdtBannerAdapter.h"

#if __has_include(<GDTUnifiedBannerView.h>)
#import <GDTUnifiedBannerView.h>
#else
#import "GDTUnifiedBannerView.h"
#endif

#import "AdvanceBanner.h"
#import "AdvLog.h"


@interface GdtBannerAdapter () <GDTUnifiedBannerViewDelegate>
@property (nonatomic, strong) GDTUnifiedBannerView *gdt_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;


@property (nonatomic, assign) BOOL isBided;
@property (nonatomic, assign) BOOL isDidload;
@property (nonatomic, assign) BOOL isClose;

@end

@implementation GdtBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _gdt_ad = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:_supplier.adspotid viewController:_adspot.viewController];
        _gdt_ad.animated = NO;
        _gdt_ad.autoSwitchInterval = _adspot.refreshInterval;
        _gdt_ad.delegate = self;

    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载广点通 supplier: %@", _supplier);
        
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_gdt_ad loadAdAndShow];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"广点通加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"广点通 成功");
    if (_isDidload) {
        return;
    }
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"广点通 失败");
    [_adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self.gdt_ad);
    
    if (_gdt_ad) {
        //        NSLog(@"广点通 释放了");
        [_gdt_ad removeFromSuperview];
        _gdt_ad.delegate = nil;
        _gdt_ad = nil;
        [_adspot.adContainer removeFromSuperview];
    }
}
    
- (void)showAd {
    if (_gdt_ad) {
        [_adspot.adContainer addSubview:_gdt_ad];
    } else {
        [self deallocAdapter];
    }

}


// MARK: ======================= GDTUnifiedBannerViewDelegate =======================
/**
 *  广告数据拉取成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView {
    _supplier.supplierPrice = [unifiedBannerView eCPM];
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
}

/**
 *  请求广告数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error {
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
- (void)unifiedBannerViewWillExpose:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didShowAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didShowAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(bannerView:didClickAdWithSpotId:extra:)]) {
        [self.delegate bannerView:self.adspot.adContainer didClickAdWithSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(GDTUnifiedBannerView *)unifiedBannerView {
    [_gdt_ad removeFromSuperview];
    _gdt_ad = nil;
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
