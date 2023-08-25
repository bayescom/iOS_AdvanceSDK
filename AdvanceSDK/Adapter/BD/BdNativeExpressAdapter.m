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
@class BaiduMobAdActButton;

@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation BdNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdNative alloc] init];
        _bd_ad.adDelegate = self;
        _bd_ad.publisherId = _supplier.mediaid;
        _bd_ad.adUnitTag = _supplier.adspotid;
        _bd_ad.presentAdViewController = _adspot.viewController;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_bd_ad requestNativeAds];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (self.bd_ad) {
        self.bd_ad.adDelegate = nil;
        self.bd_ad = nil;
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);

    [self deallocAdapter];
}

- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (nativeAds == nil || nativeAds.count == 0) {
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) {
            return;
        }

    } else {
        _supplier.supplierPrice = [[nativeAds.firstObject getECPMLevel] integerValue];
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        
        self.nativeAds= [NSMutableArray array];
        
        for (int i = 0; i < nativeAds.count; i++) {
            BaiduMobAdNativeAdObject *object = nativeAds[i];
            object.interationDelegate = self;
            
            //展现前检查是否过期，通常广告过期时间为30分钟。如果过期，请放弃展示并重新请求
            if ([object isExpired]) {
                continue;
            }
            
            BaiduMobAdSmartFeedView *view = [[BaiduMobAdSmartFeedView alloc] initWithObject:object frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 351)];
            
            [view reSize];
            
            AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] initWithViewController:_adspot.viewController];
            TT.expressView = view;
            TT.identifier = _supplier.identifier;
            TT.price = ([[object getECPMLevel] integerValue] == 0) ?  _supplier.supplierPrice : [[object getECPMLevel] integerValue];
            [self.nativeAds addObject:TT];
            
            //非智能优选信息流无法使用BaiduMobAdSmartFeedView 推荐对init的view判空
            if (view) {
                if ([self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
                    [self.delegate nativeExpressAdViewRenderSuccess:TT spotId:self.adspot.adspotid extra:self.adspot.ext];
                }
            } else {
                if ([self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
                    [self.delegate nativeExpressAdViewRenderFail:TT spotId:self.adspot.adspotid extra:self.adspot.ext];
                }
            }
        }
        
        if (_supplier.isParallel == YES) {
//            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }
        
        if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
            [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
        }
    }

}

//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }

    _bd_ad = nil;

}

// 负反馈点击选项回调
- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
//    NSLog(@"智能优选负反馈点击：%@", object);
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:adView];
    if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
        [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
    }

}


//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流被点击:%@ - %@", nativeAdView, object);
    [_adspot reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    
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
//    NSLog(@"信息流广告曝光成功:%@ - %@", nativeAdView, object);
    AdvanceNativeExpressAd *nativeAd = [self returnExpressViewWithAdView:nativeAdView];

    if (nativeAd) {
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }

    }
    
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
//    NSLog(@"信息流广告曝光失败:%@ - %@，reason：%d", nativeAdView, object, reason);
//    [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    
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
//    NSLog(@"信息流广告百香果点击回调");
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
