//
//  AdvBiddingNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/8/8.
//

#import "AdvBiddingNativeExpressAdapter.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressView.h"

@interface AdvBiddingNativeExpressAdapter ()<ABUNativeAdsManagerDelegate, ABUNativeAdViewDelegate, ABUNativeAdVideoDelegate>
@property (nonatomic, strong) ABUNativeAdsManager *adManager;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray<__kindof AdvanceNativeExpressView *> *views;

@end

@implementation AdvBiddingNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;

        self.adManager = [[ABUNativeAdsManager alloc] initWithAdUnitID:_supplier.adspotid adSize:_adspot.adSize];
        self.adManager.rootViewController = _adspot.viewController;
        self.adManager.startMutedIfCan = YES;
        self.adManager.delegate = self;

    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Bidding supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    
    if([ABUAdSDKManager configDidLoad]){
        [self.adManager loadAdDataWithCount:1];
    }else{
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(AdvBiddingNativeExpressAdapter  *observer) {
            [observer.adManager loadAdDataWithCount:1];
        }];
    }

//    [self.adManager loadAdDataWithCount:1];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Bidding加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Bidding 成功");
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
        [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"Bidding 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    
}

- (void)dealloc {

}

# pragma mark ---<ABUNativeAdsManagerDelegate>---
- (void)nativeAdsManagerSuccessToLoad:(ABUNativeAdsManager *_Nonnull)adsManager nativeAds:(NSArray<ABUNativeAdView *> *_Nullable)nativeAdViewArray {
    if (nativeAdViewArray == nil || nativeAdViewArray.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateFailed;
            return;
        }

    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        
        NSMutableArray *temp = [NSMutableArray array];
        for (ABUNativeAdView *view in nativeAdViewArray) {
//            view.controller = _adspot.viewController;
            view.rootViewController = _adspot.viewController;
            view.delegate = self;
            view.videoDelegate = self;

            AdvanceNativeExpressView *TT = [[AdvanceNativeExpressView alloc] initWithViewController:_adspot.viewController];
            TT.expressView = view;
            TT.identifier = _supplier.identifier;
            [temp addObject:TT];

        }
        
        self.views = temp;
        if (_supplier.isParallel == YES) {
//            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }

        
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:temp];
        }
        
    }
}

- (void)nativeAdsManager:(ABUNativeAdsManager *_Nonnull)adsManager didFailWithError:(NSError *_Nullable)error {
    ADV_LEVEL_INFO_LOG(@"%s:%@", __func__, error);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

}

# pragma mark ---<ABUNativeAdViewDelegate>---
- (void)nativeAdExpressViewRenderSuccess:(ABUNativeAdView *_Nonnull)nativeExpressAdView {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
            [_delegate advanceNativeExpressOnAdRenderSuccess:expressView];
        }
    }

}

/**
 * This method is called when a nativeExpressAdView failed to render
 */
- (void)nativeAdExpressViewRenderFail:(ABUNativeAdView *_Nonnull)nativeExpressAdView error:(NSError *_Nullable)error {
    ADV_LEVEL_INFO_LOG(@"%s:%@", __func__, error);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
            [_delegate advanceNativeExpressOnAdRenderFail:expressView];
        }
    }
}

/**
 This method is called when native ad slot has been shown.
 */
- (void)nativeAdDidBecomeVisible:(ABUNativeAdView *_Nonnull)nativeAdView {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    
    ABURitInfo *info = [nativeAdView getShowEcpmInfo];
    ADV_LEVEL_INFO_LOG(@"ecpm:%@", info.ecpm);
    ADV_LEVEL_INFO_LOG(@"platform:%@", info.adnName);
    ADV_LEVEL_INFO_LOG(@"ritID:%@", info.slotID);
    ADV_LEVEL_INFO_LOG(@"requestID:%@", info.requestID ?: @"None");
    _supplier.supplierPrice = (info.ecpm) ? info.ecpm.integerValue : 0;
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    [_adspot reportWithType:AdvanceSdkSupplierRepoGMBidding supplier:_supplier error:nil];
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)nativeAdView];
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
            [_delegate advanceNativeExpressOnAdShow:expressView];
        }
    }

}

/**
 This method is called when native ad is clicked.
 */
- (void)nativeAdDidClick:(ABUNativeAdView *_Nonnull)nativeAdView withView:(UIView *_Nullable)view {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)nativeAdView];
    
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
            [_delegate advanceNativeExpressOnAdClicked:expressView];
        }
    }
}

/**
 * Sent after an ad view is clicked, a ad landscape view will present modal content
 */
- (void)nativeAdViewWillPresentFullScreenModal:(ABUNativeAdView *_Nonnull)nativeAdView {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

- (void)nativeAdExpressViewDidClosed:(ABUNativeAdView *)nativeAdView closeReason:(NSArray<NSDictionary *> *)filterWords {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);

    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:(UIView *)nativeAdView];
    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
            [_delegate advanceNativeExpressOnAdClosed:expressView];
        }
    }
}

# pragma mark ---<ABUNativeAdVideoDelegate>---
/**
 This method is called when videoadview playback status changed.
 @param playerState : player state after changed
 */
- (void)nativeAdVideo:(ABUNativeAdView *_Nullable)nativeAdView stateDidChanged:(ABUPlayerPlayState)playerState {
    ADV_LEVEL_INFO_LOG(@"%s:%ld", __func__, (long)playerState);
}

/**
 This method is called when videoadview's finish view is clicked.
 */
- (void)nativeAdVideoDidClick:(ABUNativeAdView *_Nullable)nativeAdView {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

/**
 This method is called when videoadview end of play.
 */
- (void)nativeAdVideoDidPlayFinish:(ABUNativeAdView *_Nullable)nativeAdView {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

- (AdvanceNativeExpressView *)returnExpressViewWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.views.count; i++) {
        AdvanceNativeExpressView *temp = self.views[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}

@end
