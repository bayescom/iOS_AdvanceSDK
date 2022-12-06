//
//  AdvBiddingSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2022/7/27.
//

#import "AdvBiddingSplashAdapter.h"
# if __has_include(<ABUAdSDK/ABUAdSDK.h>)
#import <ABUAdSDK/ABUAdSDK.h>
#else
#import <Ads-Mediation-CN/ABUAdSDK.h>
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"

@interface AdvBiddingSplashAdapter ()<ABUSplashAdDelegate>
{
     
    NSInteger _timeout;
    NSInteger _timeout_stamp;

}
@property (nonatomic, strong) ABUSplashAd *splashAd;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, strong) UIView *customSplashView;
@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation AdvBiddingSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
        self.splashAd = [[ABUSplashAd alloc] initWithAdUnitID:_supplier.adspotid];
        self.splashAd.delegate = self;
        self.splashAd.rootViewController = _adspot.viewController;

    }
    return self;
}


- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载bidding supplier: %@", _supplier);
    NSInteger parallel_timeout = _supplier.timeout;
    if (parallel_timeout == 0) {
        parallel_timeout = 3000;
    }

    self.splashAd.tolerateTimeout = parallel_timeout / 1000.0;
//    self.splashAd.tolerateTimeout = 1.5;

    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    
    // 设置logo
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        UIImageView *bottomView = [[UIImageView alloc] init];
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        bottomView.image = _adspot.logoImage;
        bottomView.frame = CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, [UIScreen mainScreen].bounds.size.width, real_h);
        self.splashAd.customBottomView = bottomView;
    }
    
    __weak typeof(self) _self = self;
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    if([ABUAdSDKManager configDidLoad]) {
        //当前配置拉取成功，直接loadAdData
        [self.splashAd loadAdData];
    } else {
        //当前配置未拉取成功，在成功之后会调用该callback
        [ABUAdSDKManager addConfigLoadSuccessObserver:self withAction:^(id  _Nonnull observer) {
            __strong typeof(_self) self = _self;
            [self.splashAd loadAdData];
        }];
    }

}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"bidding加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"bidding 成功");
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    [self showAd];

    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"bidding 失败");
    [self.adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
//    ADV_LEVEL_INFO_LOG(@"===> %s %@", __func__, [NSThread currentThread]);
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);

    if (_splashAd) {
        [_splashAd destoryAd];
        _splashAd.delegate = nil;
        _splashAd = nil;
        [_imgV removeFromSuperview];
    }
}

- (void)showAd {
    // 设置logo
    [self.splashAd showInWindow:[[UIApplication sharedApplication] keyWindow]];
}

- (void)splashAdDidLoad:(ABUSplashAd *)splashAd {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    [self showAd];
}

- (void)splashAd:(ABUSplashAd *)splashAd didFailWithError:(NSError *)error {
    ADV_LEVEL_INFO_LOG(@"%s-error:%@", __func__, error);
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    [self deallocAdapter];
}

- (void)splashAdDidClose:(ABUSplashAd *_Nonnull)splashAd {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
//    [self deallocAdapter];
    
}

- (void)splashAdWillVisible:(ABUSplashAd *_Nonnull)splashAd {
    ABURitInfo *info = [splashAd getShowEcpmInfo];
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    ADV_LEVEL_INFO_LOG(@"ecpm:%@", info.ecpm);
    ADV_LEVEL_INFO_LOG(@"platform:%@", info.adnName);
    ADV_LEVEL_INFO_LOG(@"ritID:%@", info.slotID);
    ADV_LEVEL_INFO_LOG(@"requestID:%@", info.requestID ?: @"None");
    _supplier.supplierPrice = (info.ecpm) ? info.ecpm.integerValue : 0;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoGMBidding supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }

}

- (void)splashAdDidClick:(ABUSplashAd *)splashAd {
    [_adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)splashAdCountdownToZero:(ABUSplashAd *)splashAd {
//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
//        [self.delegate advanceSplashOnAdCountdownToZero];
//    }
//    [self deallocAdapter];

}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}


@end
