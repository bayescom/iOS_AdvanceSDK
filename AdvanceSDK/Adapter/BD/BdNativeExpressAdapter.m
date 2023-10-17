//
//  BdNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "BdNativeExpressAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdNative.h>)
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#import <BaiduMobAdSDK/BaiduMobAdSmartFeedView.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#import "BaiduMobAdSDK/BaiduMobAdSmartFeedView.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvanceAdapter.h"

@class BaiduMobAdActButton;

@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate, AdvanceAdapter>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) BaiduMobAdNativeAdObject *feedAdObj;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation BdNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdNative alloc] init];
        _bd_ad.adDelegate = self;
        _bd_ad.publisherId = _supplier.mediaid;
        _bd_ad.adUnitTag = _supplier.adspotid;
        _bd_ad.presentAdViewController = _adspot.viewController;
        _nativeAds = [NSMutableArray array];
    }
    return self;
}

- (void)loadAd {
    [_bd_ad requestNativeAds];
}

- (void)winnerAdapterToShowAd {
    
    /// 广告加载成功回调
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
    
    /// 渲染广告
    /// 展现前检查是否过期，通常广告过期时间为30分钟。如果过期，请放弃展示并重新请求
    if (![self.feedAdObj isExpired]) {
        if ([self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [self.delegate nativeExpressAdViewRenderSuccess:self.nativeAds.firstObject spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [self.delegate nativeExpressAdViewRenderFail:self.nativeAds.firstObject spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
}

- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"BDAdErrorDomain" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    BaiduMobAdNativeAdObject *object = nativeAds.firstObject;
    BaiduMobAdSmartFeedView *view = [[BaiduMobAdSmartFeedView alloc] initWithObject:object frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 351)];
    object.interationDelegate = self;
    [view reSize];
    self.feedAdObj = object;
    
    AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
    TT.expressView = view;
    TT.identifier = _supplier.identifier;
    [self.nativeAds addObject:TT];
    
    /// 非智能优选信息流无法使用BaiduMobAdSmartFeedView 推荐对init的view判空
    if (view) {
        [self.adspot.manager setECPMIfNeeded:[[nativeAds.firstObject getECPMLevel] integerValue] supplier:_supplier];
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
    } else {
        NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:-1 userInfo:@{@"desc":@"百度广告拉取失败"}];
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
    }

}

//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:-1 userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

// 负反馈点击选项回调
- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:adView];
    if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
        [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {

}

//广告曝光成功
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
        [self.nativeAds removeObject:nativeAd];
    }

}

// 联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{

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
