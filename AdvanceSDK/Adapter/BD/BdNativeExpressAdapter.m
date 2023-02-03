//
//  BdNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/31.
//

#import "BdNativeExpressAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdNative.h>)
#import <BaiduMobAdSDK/BaiduMobAdNative.h>
#import <BaiduMobAdSDK/BaiduMobAdSmartFeedView.h>
#import <BaiduMobAdSDK/BaiduMobAdNativeAdObject.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdNative.h"
#import "BaiduMobAdSDK/BaiduMobAdSmartFeedView.h"
#import "BaiduMobAdSDK/BaiduMobAdNativeAdObject.h"
#endif

#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressView.h"
@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate, BaiduMobAdNativeInterationDelegate>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressView *> *views;

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
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
        [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
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
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) {
            return;
        }

    } else {
        _supplier.supplierPrice = [[nativeAds.firstObject getECPMLevel] integerValue];
        [_adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        NSMutableArray *temp = [NSMutableArray array];
        
        BaiduMobAdNativeAdObject *object = nativeAds.firstObject;
        object.interationDelegate = self;
//        if ([object isExpired]) {
//            continue;
//        }
        // BDview
        BaiduMobAdSmartFeedView *view = [[BaiduMobAdSmartFeedView alloc]initWithObject:object frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
//            [view addGestureRecognizer:tapGesture];

        [view setVideoMute:YES];
        
//            [view handleClick];
//            [view trackImpression];
        [view reSize];

        // advanceView
        AdvanceNativeExpressView *TT = [[AdvanceNativeExpressView alloc] initWithViewController:_adspot.viewController];
        TT.expressView = view;
        TT.identifier = _supplier.identifier;
        TT.price = ([[object getECPMLevel] integerValue] == 0) ?  _supplier.supplierPrice : [[object getECPMLevel] integerValue];

        [temp addObject:TT];

        self.views = temp;
        if (_supplier.isParallel == YES) {
//            NSLog(@"修改状态: %@", _supplier);
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }

        
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
    }

}

//广告返回失败
- (void)nativeAdsFailLoad:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000030 + reason userInfo:@{@"desc":@"百度广告拉取失败"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }

    _bd_ad = nil;

}

// 负反馈点击选项回调
- (void)nativeAdDislikeClick:(UIView *)adView reason:(BaiduMobAdDislikeReasonType)reason; {
//    NSLog(@"智能优选负反馈点击：%@", object);
    AdvanceNativeExpressView *temp = [self returnExpressViewWithAdView:adView];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
        [_delegate advanceNativeExpressOnAdClosed:temp];
    }

}


//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流被点击:%@ - %@", nativeAdView, object);
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:nativeAdView];

    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
            [_delegate advanceNativeExpressOnAdClicked:expressView];
        }
    }
}

//广告详情页被关闭，如果为视频广告，可选择继续播放视频
- (void)didDismissLandingPage:(UIView *)nativeAdView {
//    NSLog(@"信息流落地页被关闭");
//    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClosed:)]) {
//        [_delegate advanceNativeExpressOnAdClosed:nativeAdView];
//    }

}

//广告曝光成功
- (void)nativeAdExposure:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流广告曝光成功:%@ - %@", nativeAdView, object);
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:nativeAdView];

    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
            [_delegate advanceNativeExpressOnAdRenderSuccess:expressView];
        }
        
        [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
            [_delegate advanceNativeExpressOnAdShow:expressView];
        }

    }
    
}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
//    NSLog(@"信息流广告曝光失败:%@ - %@，reason：%d", nativeAdView, object, reason);
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    
    AdvanceNativeExpressView *expressView = [self returnExpressViewWithAdView:nativeAdView];

    if (expressView) {
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
            [_delegate advanceNativeExpressOnAdRenderFail:expressView];
        }
        [self.views removeObject:expressView];
    }

}

// 联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
//    NSLog(@"信息流广告百香果点击回调");
}

- (void)tapGesture:(UIGestureRecognizer *)sender {
    UIView *view = sender.view ;

    if ([view isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
        BaiduMobAdSmartFeedView *adView = (BaiduMobAdSmartFeedView *)view;
        [adView handleClick];
        return;
    }
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
