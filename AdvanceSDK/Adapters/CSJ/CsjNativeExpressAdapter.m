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
#import "AdvanceAdapter.h"

@interface CsjNativeExpressAdapter () <BUNativeExpressAdViewDelegate, AdvanceAdapter>
@property (nonatomic, strong) BUNativeExpressAdManager *csj_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray <__kindof AdvanceNativeExpressAd *> * nativeAds;

@end

@implementation CsjNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
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

- (void)loadAd {
    [_csj_ad loadAdDataWithCount:1];
}

- (void)winnerAdapterToShowAd {
    /// 广告加载成功回调
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
    
    /// 渲染广告
    if (!_adspot.isGroMoreADN) {
        [self renderNativeAdView];
    }
}

/// 渲染广告
- (void)renderNativeAdView {
    [self.nativeAds enumerateObjectsUsingBlock:^(__kindof AdvanceNativeExpressAd * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BUNativeExpressAdView *expressView = (BUNativeExpressAdView *)obj.expressView;
        expressView.rootViewController = self.adspot.viewController;
        [expressView render];
    }];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


// MARK: ======================= BUNativeExpressAdViewDelegate =======================
- (void)nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(nonnull NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (!views.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"BUNative.com" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    self.nativeAds = [NSMutableArray array];
    for (BUNativeExpressAdView *view in views) {
        AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
        TT.expressView = view;
        TT.identifier = _supplier.identifier;
        [self.nativeAds addObject:TT];
    }
    
    NSDictionary *ext = views.firstObject.mediaExt;
    [self.adspot.manager setECPMIfNeeded:[ext[@"price"] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
    
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)nativeExpressAdViewWillPresentScreen:(BUNativeExpressAdView *)nativeExpressAdView {
    
}


- (AdvanceNativeExpressAd *)getNativeExpressAdWithAdView:(UIView *)adView {
    for (NSInteger i = 0; i < self.nativeAds.count; i++) {
        AdvanceNativeExpressAd *temp = self.nativeAds[i];
        if (temp.expressView == adView) {
            return temp;
        }
    }
    return nil;
}

@end
