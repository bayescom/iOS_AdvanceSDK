//
//  GroMoreNativeExpressTrigger.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/10/25.
//

#import "GroMoreNativeExpressTrigger.h"
#import <ABUAdSDK/ABUAdSDK.h>
#import "AdvanceNativeExpress.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvLog.h"
#import "GroMoreBiddingManager.h"

@interface GroMoreNativeExpressTrigger () <ABUNativeAdsManagerDelegate, ABUNativeAdViewDelegate, ABUNativeAdVideoDelegate>
/// gromore 广告位对象
@property (nonatomic, strong) ABUNativeAdsManager *gmAdManager;
/// advance 广告位对象 从最外层传递进来 负责 load and show
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) Gro_more *groMore;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation GroMoreNativeExpressTrigger

- (instancetype)initWithGroMore:(Gro_more *)groMore adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _groMore = groMore;
        _gmAdManager = [[ABUNativeAdsManager alloc] initWithAdUnitID:groMore.gromore_params.adspotid adSize:_adspot.adSize];
        _gmAdManager.delegate = self;
        _gmAdManager.rootViewController = _adspot.viewController;
        _gmAdManager.startMutedIfCan = _adspot.muted;
        _gmAdManager.bidNotify = YES;
    }
    return self;
}

- (void)loadAd {
    if([ABUAdSDKManager configDidLoad]) {
        [self.gmAdManager loadAdDataWithCount:1];
    } else {
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            [self.gmAdManager loadAdDataWithCount:1];
        }];
    }
}

#pragma mark: - ABUNativeAdsManagerDelegate
/// Native 广告加载成功回调
- (void)nativeAdsManagerSuccessToLoad:(ABUNativeAdsManager *_Nonnull)adsManager nativeAds:(NSArray<ABUNativeAdView *> *_Nullable)nativeAdViewArray {
    if (!nativeAdViewArray.count) {
        NSError *error = [NSError errorWithDomain:@"ABUNative.com" code:1 userInfo:@{@"msg":@"无广告返回"}];
        [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
        if ([self.delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
            [self.delegate didFailLoadingADSourceWithSpotId:self.adspot.adspotid error:error description:@{}];
        }
        return;
    }
    
    self.nativeAds = [NSMutableArray array];
    for (ABUNativeAdView *view in nativeAdViewArray) {
        AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
        TT.expressView = view;
        TT.identifier = @"gromore";
        [self.nativeAds addObject:TT];
        view.delegate = self;
        view.videoDelegate = self;
//        view.rootViewController = _adspot.viewController;
        [view render];
    }
    
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoSucceed groMore:_groMore error:nil];
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
}

/// Native 广告加载失败回调
- (void)nativeAdsManager:(ABUNativeAdsManager *_Nonnull)adsManager didFailWithError:(NSError *_Nullable)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
    if ([self.delegate respondsToSelector:@selector(didFailLoadingADSourceWithSpotId:error:description:)]) {
        [self.delegate didFailLoadingADSourceWithSpotId:self.adspot.adspotid error:error description:@{}];
    }
}

#pragma mark: - ABUNativeAdViewDelegate
/// 模板广告渲染成功回调
- (void)nativeAdExpressViewRenderSuccess:(ABUNativeAdView *_Nonnull)nativeExpressAdView {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 模板广告渲染失败回调
- (void)nativeAdExpressViewRenderFail:(ABUNativeAdView *_Nonnull)nativeExpressAdView error:(NSError *_Nullable)error {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoFailed groMore:_groMore error:error];
    
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeExpressAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 广告展示回调
- (void)nativeAdDidBecomeVisible:(ABUNativeAdView *_Nonnull)nativeAdView {
    /// 广告曝光才能获取到竞价
    ABURitInfo *info = [nativeAdView getShowEcpmInfo];
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoImped groMore:_groMore error:nil];
    
    GroMoreBiddingManager.policyModel.gro_more.gromore_params.bidPrice = info.ecpm.integerValue;
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 广告点击事件回调
- (void)nativeAdDidClick:(ABUNativeAdView *_Nonnull)nativeAdView withView:(UIView *_Nullable)view {
    [self.adspot.manager reportGroMoreEventWithType:AdvanceSdkSupplierRepoClicked groMore:_groMore error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 模板广告点击关闭时触发
- (void)nativeAdExpressViewDidClosed:(ABUNativeAdView *_Nullable)nativeAdView closeReason:(NSArray<NSDictionary *> *_Nullable)filterWords {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:(UIView *)nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

#pragma mark: - ABUNativeAdVideoDelegate
/// 当视频播放状态改变之后触发
- (void)nativeAdVideo:(ABUNativeAdView *_Nullable)nativeAdView stateDidChanged:(ABUPlayerPlayState)playerState{}


/// 广告视图中视频视图被点击时触发
- (void)nativeAdVideoDidClick:(ABUNativeAdView *_Nullable)nativeAdView{}


/// 广告视图中视频播放完成时触发
- (void)nativeAdVideoDidPlayFinish:(ABUNativeAdView *_Nullable)nativeAdView{}

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
