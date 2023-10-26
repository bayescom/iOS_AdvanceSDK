//
//  KsNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/23.
//

#import "KsNativeExpressAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
#import "KSAdSDK.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvanceAdapter.h"

@interface KsNativeExpressAdapter ()<KSFeedAdsManagerDelegate, KSFeedAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) KSFeedAdsManager *ks_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray<KSFeedAd *> *feedAdArray;
@property (nonatomic, strong) NSMutableArray<AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation KsNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _ks_ad = [[KSFeedAdsManager alloc] initWithPosId:_supplier.adspotid size:_adspot.adSize];
        _ks_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_ks_ad loadAdDataWithCount:1];
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
    [self.feedAdArray enumerateObjectsUsingBlock:^(KSFeedAd * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.delegate = self;
        obj.videoSoundEnable = !self.adspot.muted;
        AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:obj.feedView];
        if ([self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [self.delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


- (void)feedAdsManagerSuccessToLoad:(KSFeedAdsManager *)adsManager nativeAds:(NSArray<KSFeedAd *> *_Nullable)feedAdDataArray {
    self.feedAdArray = feedAdDataArray;
    if (!feedAdDataArray.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"KSADErrorDomain" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    self.nativeAds = [NSMutableArray array];
    for (KSFeedAd *ad in feedAdDataArray) {
        AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
        TT.expressView = ad.feedView;
        TT.identifier = _supplier.identifier;
        [self.nativeAds addObject:TT];
    }
    
    [self.adspot.manager setECPMIfNeeded:feedAdDataArray.firstObject.ecpm supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)feedAdsManager:(KSFeedAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)feedAdViewWillShow:(KSFeedAd *)feedAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)feedAd.feedView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)feedAdDidClick:(KSFeedAd *)feedAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)feedAd.feedView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)feedAdDislike:(KSFeedAd *)feedAd {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)feedAd.feedView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)feedAdDidShowOtherController:(KSFeedAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    
}

- (void)feedAdDidCloseOtherController:(KSFeedAd *)nativeAd interactionType:(KSAdInteractionType)interactionType {
    
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
