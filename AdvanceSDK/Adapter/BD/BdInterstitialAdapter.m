//
//  BdInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/6/21.
//

#import "BdInterstitialAdapter.h"
#import "AdvanceInterstitial.h"
#import "AdvLog.h"

#if __has_include(<BaiduMobAdSDK/BaiduMobAdExpressInterstitial.h>)
#import <BaiduMobAdSDK/BaiduMobAdExpressInterstitial.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdExpressInterstitial.h"
#endif

@interface BdInterstitialAdapter ()<BaiduMobAdExpressIntDelegate>
@property (nonatomic, strong) BaiduMobAdExpressInterstitial *bd_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation BdInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = (AdvanceInterstitial *)adspot;
        _supplier = supplier;
        self.bd_ad = [[BaiduMobAdExpressInterstitial alloc] init];
        self.bd_ad.publisherId = _supplier.mediaid;
        self.bd_ad.adUnitTag = _supplier.adspotid;
//        self.bd_ad.publisherId = @"ccb60059";
//        self.bd_ad.adUnitTag = @"2058554";

        self.bd_ad.delegate = self;
    }
    return self;
}


- (void)loadAd {
    [super loadAd];
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self.bd_ad load];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }

}

- (void)supplierStateFailed {
//    NSLog(@"失败 失败失败失败失败失败失败失败  %ld", _supplier.priority);
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)deallocAdapter {
    
}


- (void)showAd {
    [self.bd_ad showFromViewController:self.adspot.viewController];
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

- (void)interstitialAdLoaded:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial loaded 请求成功");
    
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
//    NSLog(@"穿山甲插屏视频拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }

    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}

- (void)interstitialAdLoadFailed:(BaiduMobAdExpressInterstitial *)interstitial withError:(BaiduMobFailReason)reason {
    NSLog(@"ExpressInterstitial failed 请求失败");
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000020 + reason userInfo:@{@"desc":@"百度广告请求错误"}];
    
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }

}

- (void)interstitialAdDownloadSucceeded:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial downloadSucceeded 缓存成功");
}

- (void)interstitialAdDownLoadFailed:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial downloadFailed 缓存失败");
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000220 userInfo:@{@"desc":@"百度广告缓存错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    self.bd_ad = nil;
}

- (void)interstitialAdExposure:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial exposure 曝光成功");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

- (void)interstitialAdExposureFail:(BaiduMobAdExpressInterstitial *)interstitial withError:(int)reason {
    NSLog(@"ExpressInterstitial exposure 展现失败");
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000120 + reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    self.bd_ad = nil;
}

- (void)interstitialAdDidClick:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial click 发生点击");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)interstitialAdDidLPClose:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial lpClose 落地页关闭");
}

- (void)interstitialAdDidClose:(BaiduMobAdExpressInterstitial *)interstitial {
    NSLog(@"ExpressInterstitial close 点击关闭");
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}


@end