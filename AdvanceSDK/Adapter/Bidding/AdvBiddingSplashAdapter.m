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
        self.splashAd = [[ABUSplashAd alloc] initWithAdUnitID:_supplier.mediaid];
        self.splashAd.delegate = self;
        self.splashAd.rootViewController = _adspot.viewController;

    }
    return self;
}


- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载bidding supplier: %@", _supplier);
    if (self.adspot.timeout) {
        if (self.adspot.timeout > 500) {
            self.splashAd.tolerateTimeout = _adspot.timeout / 1000.0;
        }
    }
    
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    
    // 设置logo
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        UIImageView *bottomView = [[UIImageView alloc] init];
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        bottomView.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
        self.splashAd.customBottomView = bottomView;
    }

    [self.splashAd loadAdData];

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
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    self.splashAd = nil;
    [self.imgV removeFromSuperview];
}

- (void)showAd {
    // 设置logo
}

@end
