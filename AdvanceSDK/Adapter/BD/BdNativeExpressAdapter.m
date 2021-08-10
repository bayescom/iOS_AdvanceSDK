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
@interface BdNativeExpressAdapter ()<BaiduMobAdNativeAdDelegate>
@property (nonatomic, strong) BaiduMobAdNative *bd_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, weak) UIViewController *controller;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSMutableArray<__kindof BaiduMobAdSmartFeedView *> *views;

@end

@implementation BdNativeExpressAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceNativeExpress *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdNative alloc] init];
        _bd_ad.delegate = self;
        _bd_ad.publisherId = _supplier.mediaid;
        _bd_ad.adId = _supplier.adspotid;
        _bd_ad.presentAdViewController = _adspot.viewController;
    }
    return self;
}

- (void)loadAd {
    int adCount = 1;
    
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADV_LEVEL_INFO_LOG(@"广点通 成功");
        if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdLoadSuccess:)]) {
            [_delegate advanceNativeExpressOnAdLoadSuccess:self.views];
        }
//        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADV_LEVEL_INFO_LOG(@"广点通 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADV_LEVEL_INFO_LOG(@"广点通 正在加载中");
    } else {
        ADV_LEVEL_INFO_LOG(@"广点通 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_bd_ad requestNativeAds];
    }

}

- (void)dealloc {
//    ADVLog(@"%s", __func__);
}


- (void)nativeAdObjectsSuccessLoad:(NSArray*)nativeAds nativeAd:(BaiduMobAdNative *)nativeAd {
    if (nativeAds == nil || nativeAds.count == 0) {
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:[NSError errorWithDomain:@"" code:100000 userInfo:@{@"msg":@"无广告返回"}]];
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateFailed;
            return;
        }

    } else {
        [_adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
        NSMutableArray *views = [NSMutableArray array];
        for (BaiduMobAdNativeAdObject *object in nativeAds) {
            if ([object isExpired]) {
                continue;
            }
            BaiduMobAdSmartFeedView *view = [[BaiduMobAdSmartFeedView alloc]initWithObject:object frame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, CGFLOAT_MIN)];
            [views addObject:view];
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
            [view addGestureRecognizer:tapGesture];

            [view setVideoMute:YES];
            
//            [view handleClick];
            [view trackImpression];
        }
        self.views = views;
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

    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

    _bd_ad = nil;

}

//广告被点击，打开后续详情页面，如果为视频广告，可选择暂停视频
- (void)nativeAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object {
//    NSLog(@"信息流被点击:%@ - %@", nativeAdView, object);
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdClicked:)]) {
        [_delegate advanceNativeExpressOnAdClicked:nativeAdView];
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
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderSuccess:)]) {
        [_delegate advanceNativeExpressOnAdRenderSuccess:nativeAdView];
    }
    
    [_adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdShow:)]) {
        [_delegate advanceNativeExpressOnAdShow:nativeAdView];
    }

}

//广告曝光失败
- (void)nativeAdExposureFail:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object failReason:(int)reason {
//    NSLog(@"信息流广告曝光失败:%@ - %@，reason：%d", nativeAdView, object, reason);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
    if ([_delegate respondsToSelector:@selector(advanceNativeExpressOnAdRenderFail:)]) {
        [_delegate advanceNativeExpressOnAdRenderFail:nativeAdView];
    }

    [self.views removeObject:nativeAdView];
}

// 联盟官网点击跳转
- (void)unionAdClicked:(UIView *)nativeAdView nativeAdDataObject:(BaiduMobAdNativeAdObject *)object{
//    NSLog(@"信息流广告百香果点击回调");
}

- (void)tapGesture:(UIGestureRecognizer *)sender {
    UIView *view = sender.view ;
    NSInteger index = [self.views indexOfObject:view];
    if (self.views.count <= index) {
        return;
    }

    if ([view isKindOfClass:[BaiduMobAdSmartFeedView class]]) {
        BaiduMobAdSmartFeedView *adView = (BaiduMobAdSmartFeedView *)view;
        [adView handleClick];
        return;
    }
}



@end
