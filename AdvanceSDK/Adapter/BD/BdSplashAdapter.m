//
//  BdSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//
#if __has_include(<BaiduMobAdSDK/BaiduMobAdSplash.h>)
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdSplash.h"
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"


#import "BdSplashAdapter.h"
@interface BdSplashAdapter ()<BaiduMobAdSplashDelegate>
@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, strong) UIView *customSplashView;
@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation BdSplashAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
        _bd_ad = [[BaiduMobAdSplash alloc] init];
        _bd_ad.AdUnitTag = supplier.adspotid;
    }
    return self;
}

- (void)loadAd {

    if (!_bd_ad) {
        [self deallocAdapter];
        return;
    }
    _bd_ad.delegate = self;
    if (self.adspot.timeout) {
        if (self.adspot.timeout > 500) {
            _bd_ad.timeout = _adspot.timeout / 1000.0;
        }
    }
    
    ADVLog(@"加载百度 supplier: %@", _supplier);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"百度 成功");
        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"百度 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
        [self deallocAdapter];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"百度 正在加载中");
    } else {
        ADVLog(@"百度 load ad");
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        
        UIWindow *window = [UIApplication sharedApplication].adv_getCurrentWindow;
        if (_adspot.logoImage) {
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, window.frame.size.height - real_h, real_w, real_h)];
            self.imgV.userInteractionEnabled = YES;
            self.imgV.image = _adspot.logoImage;
            self.imgV.hidden = YES;

            
            _bd_ad.adSize = CGSizeMake(window.frame.size.width, window.frame.size.height - self.imgV.frame.size.height);

        } else {
            _bd_ad.adSize = CGSizeMake(window.frame.size.width, window.frame.size.height);
        }
        
        [_bd_ad load];
    }

}

- (void)deallocAdapter {
//    _gdt_ad = nil;
    [self.customSplashView removeFromSuperview];
    [self.imgV removeFromSuperview];
}

- (void)showAd {
    // 设置logo
    UIWindow *window = [UIApplication sharedApplication].adv_getCurrentWindow;
    if (self.imgV) {
        [window addSubview:self.imgV];
    }
    
    if (self.bd_ad) {
        [window addSubview:self.customSplashView];
        self.customSplashView.frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height - self.imgV.frame.size.height);
        self.customSplashView.backgroundColor = [UIColor redColor];
        [self.bd_ad showInContainerView:self.customSplashView];
    
        NSLog(@"百度开屏展示%@",self.bd_ad);
    }
}

- (UIView *)customSplashView {
    if (!_customSplashView) {
        _customSplashView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].adv_getCurrentWindow.frame];
    }
    return _customSplashView;
}


- (NSString *)publisherId {
    return _supplier.mediaid;
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告落地页被关闭");
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告被移除");
    [self deallocAdapter];
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)splashDidExposure:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告曝光成功");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.bd_ad) {
        [self.delegate advanceExposured];
    }
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告展示成功");
    self.imgV.hidden = NO;
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
    NSLog(@"开屏广告展示失败 withError %d", reason);
    [self deallocAdapter];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告被点击");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
    NSLog(@"百度开屏拉取成功 %@",self.bd_ad);
    if (_supplier.isParallel == YES) {
        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }

    [self showAd];
}

- (void)splashAdLoadFail:(BaiduMobAdSplash *)splash {
    NSLog(@"开屏广告请求失败");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:nil];
//    NSLog(@"gdt ========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
    [self deallocAdapter];
}
@end
