//
//  CsjNativeExpressAdapter.m
//  AdvanceSDKDev
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "CsjNativeExpressAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
@interface CsjNativeExpressAdapter () <BUNativeExpressAdViewDelegate>
@property (nonatomic, strong) BUNativeExpressAdManager *csj_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray <__kindof AdvanceNativeExpressAd *> * nativeAds;

@end

@implementation CsjNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.ID = _supplier.adspotid;
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionFeed;
        slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
        _csj_ad = [[BUNativeExpressAdManager alloc] initWithSlot:slot adSize:_adspot.adSize];
        _csj_ad.delegate = self;

    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_csj_ad loadAdDataWithCount:1];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (self.csj_ad) {
        self.csj_ad.delegate = nil;
        self.csj_ad = nil;
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

// MARK: ======================= BUNativeExpressAdViewDelegate =======================
- (void)nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(nonnull NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (views == nil || views.count == 0) {
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) { // 并行不释放 只上报
            return;
        }

//        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//            [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
//        }
    } else {

        NSDictionary *ext = views.firstObject.mediaExt;
        _supplier.supplierPrice = [ext[@"price"] integerValue];
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        
        self.nativeAds = [NSMutableArray array];

        for (BUNativeExpressAdView *view in views) {
            
            AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] initWithViewController:_adspot.viewController];
            TT.expressView = view;
            TT.identifier = _supplier.identifier;
            TT.price = _supplier.sdk_price;
            [self.nativeAds addObject:TT];
            
            view.rootViewController = _adspot.viewController;
            [view render];

        }
        
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }

        if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
            [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
        }
    }
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdFailedWithSdkId:error:)]) {
//        [_delegate advanceNativeExpressOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }

    _csj_ad = nil;
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
//    [_adspot reportEventWithType:AdvanceSdkSupplierRepoFaileded error:error];
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
//    _csj_ad = nil;
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [_adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}


- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:(UIView *)nativeExpressAdView];

    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}
- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
    
}


- (AdvanceNativeExpressAd *)returnExpressViewWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.nativeAds.count; i++) {
        AdvanceNativeExpressAd *temp = self.nativeAds[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}


@end
