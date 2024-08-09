//
//  BdNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "BdNativeExpressAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdExpressNativeView.h>
#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvanceAdapter.h"

@class BaiduMobAdActButton;

@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate, AdvanceAdapter>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
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
        _bd_ad.baiduMobAdsWidth = @(_adspot.adSize.width);
        _bd_ad.baiduMobAdsHeight = @(_adspot.adSize.height);
        _bd_ad.presentAdViewController = _adspot.viewController;
        _bd_ad.isExpressNativeAds = YES;
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
    if (!_adspot.isGroMoreADN) {
        [self renderNativeAdView];
    }
}

/// 渲染广告
- (void)renderNativeAdView {
    [self.nativeAds enumerateObjectsUsingBlock:^(__kindof AdvanceNativeExpressAd * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        BaiduMobAdExpressNativeView *expressView = (BaiduMobAdExpressNativeView *)obj.expressView;
        expressView.interationDelegate = self;
        expressView.baseViewController = self.adspot.viewController;
        
        if (expressView.style_type == FeedType_PORTRAIT_VIDEO) {
            expressView.width = self.adspot.adSize.width * 0.8;
        }
        // 展现前检查是否过期，30分钟广告将过期
        if (![expressView isExpired]) {
            [expressView render];
        }
    }];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

// 广告返回成功
- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (!nativeAds.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"BDAdErrorDomain" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    self.nativeAds = [NSMutableArray array];
    for (BaiduMobAdExpressNativeView *view in nativeAds) {
        AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
        TT.expressView = view;
        TT.identifier = _supplier.identifier;
        [self.nativeAds addObject:TT];
    }
    
    [self.adspot.manager setECPMIfNeeded:[[nativeAds.firstObject getECPMLevel] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];

}

// 广告返回失败
- (void)nativeAdsFailLoadCode:(NSString *)errCode
                      message:(NSString *)message
                     nativeAd:(BaiduMobAdNative *)nativeAd
                     adObject:(BaiduMobAdNativeAdObject *)adObject {
    
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:-1 userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
    
}

// 广告组件渲染成功
- (void)nativeAdExpressSuccessRender:(BaiduMobAdExpressNativeView *)express nativeAd:(BaiduMobAdNative *)nativeAd {
    express.frame = ({
        CGRect frame = express.frame;
        frame.origin.x = (self.adspot.adSize.width - express.frame.size.width) / 2;
        frame;
    });
    AdvanceNativeExpressAd *advNativeAd = [self getNativeExpressAdWithAdView:express];
    if (advNativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderSuccess:advNativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

//广告曝光成功
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
            [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
        [self.nativeAds removeObject:nativeAd];
    }

}

// 负反馈点击选项回调
- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:adView];
    if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
        [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdView:nativeAdView];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}


//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {

}


// 联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{

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
