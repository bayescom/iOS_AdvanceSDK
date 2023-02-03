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
#import <objc/runtime.h>
#import <objc/message.h>

@interface BdSplashAdapter ()<BaiduMobAdSplashDelegate>
{
     
    NSInteger _timeout;
    NSInteger _timeout_stamp;

}
@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, strong) UIView *customSplashView;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, assign) BOOL isCanch;
@end

@implementation BdSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
        self.bd_ad = [[BaiduMobAdSplash alloc] init];
        self.bd_ad.AdUnitTag = supplier.adspotid;
        self.bd_ad.delegate = self;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
    if (!_bd_ad) {
        [self deallocAdapter];
        return;
    }
    NSInteger parallel_timeout = _supplier.timeout;
    if (parallel_timeout == 0) {
        parallel_timeout = 3000;
    }
    
    _bd_ad.timeout = parallel_timeout / 1000.0;
    
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
    [self.bd_ad load];
    
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");

    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [self.adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
//    _gdt_ad = nil;
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
    if (_bd_ad) {
        [_bd_ad stop];
        _bd_ad.delegate = nil;
        _bd_ad = nil;
        [self.customSplashView removeFromSuperview];
        [self.imgV removeFromSuperview];
    }
}

- (void)gmShowAd {
    [self showAdAction];
}

- (void)showAd {
    NSNumber *isGMBidding = ((NSNumber * (*)(id, SEL))objc_msgSend)((id)self.adspot, @selector(isGMBidding));

    if (isGMBidding.integerValue == 1) {
        return;
    }
    [self showAdAction];
}

- (void)showAdAction {
    // 设置logo
    UIWindow *window = [UIApplication sharedApplication].adv_getCurrentWindow;
    if (self.imgV) {
        [window addSubview:self.imgV];
    }
    
    if (self.bd_ad) {
        [window addSubview:self.customSplashView];
        self.customSplashView.frame = CGRectMake(window.frame.origin.x, window.frame.origin.y, window.frame.size.width, window.frame.size.height - self.imgV.frame.size.height);
        self.customSplashView.backgroundColor = [UIColor whiteColor];
        [self.bd_ad showInContainerView:self.customSplashView];
        
        //        NSLog(@"百度开屏展示%@",self.bd_ad);
    }
}

- (UIView *)customSplashView {
    if (!_customSplashView) {
        _customSplashView = [[UIView alloc]initWithFrame:[UIApplication sharedApplication].adv_getCurrentWindow.frame];
        _customSplashView.hidden = YES;
    }
    return _customSplashView;
}


- (NSString *)publisherId {
//    return @"fdsfds";
    return _supplier.mediaid;
}

- (void)splashDidDismissLp:(BaiduMobAdSplash *)splash {
//    NSLog(@"开屏广告落地页被关闭, ");
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
//    NSLog(@"开屏广告被移除");
//    [self deallocAdapter];
    if ([[NSDate date] timeIntervalSince1970]*1000 < _timeout_stamp) {// 关闭时的时间小于过期时间则点击了跳过
//        NSLog(@"%f, %ld",[[NSDate date] timeIntervalSince1970]*1000,  _timeout_stamp);
        if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
            [self.delegate advanceSplashOnAdSkipClicked];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
            [self.delegate advanceSplashOnAdCountdownToZero];
        }
    }
    [self.customSplashView removeFromSuperview];
    [self.imgV removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)splashDidExposure:(BaiduMobAdSplash *)splash {
//    NSLog(@"开屏广告曝光成功");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.bd_ad) {
        [self.delegate advanceExposured];
    }
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
//    NSLog(@"开屏广告展示成功");
    _timeout = 5;
    // 记录过期的时间
    _timeout_stamp = ([[NSDate date] timeIntervalSince1970] + _timeout)*1000;
    self.customSplashView.hidden = NO;
    self.imgV.hidden = NO;
}

- (void)splashlFailPresentScreen:(BaiduMobAdSplash *)splash withError:(BaiduMobFailReason)reason {
//    NSLog(@"开屏广告展示失败 withError %d", reason);
    [self deallocAdapter];
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
//    NSLog(@"开屏广告被点击");
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
//    NSLog(@"百度开屏拉取成功 %@",self.bd_ad);
    _supplier.supplierPrice = [[splash getECPMLevel] integerValue];
//    _supplier.supplierPrice = 10000;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
//        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    [self unifiedDelegate];
}

- (void)splashAdLoadFailCode:(NSString *)errCode
                     message:(NSString *)message
                    splashAd:(BaiduMobAdSplash *)nativeAd {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:[errCode integerValue] userInfo:@{@"desc":message}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) {
        return;
    }
    [self deallocAdapter];

}

//- (void)splashAdLoadFail:(BaiduMobAdSplash *)splash {
////    NSLog(@"开屏广告请求失败");
//}


- (void)unifiedDelegate {
    if (_isCanch) {
        return;
    }
    _isCanch = YES;
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    [self showAd];
}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

@end
