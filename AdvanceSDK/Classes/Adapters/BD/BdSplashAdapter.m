//
//  BdSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import "BdSplashAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSDK.h>
#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface BdSplashAdapter ()<BaiduMobAdSplashDelegate, AdvanceAdapter>

@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isAdExposed;

@end

@implementation BdSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdSplash alloc] init];
        _bd_ad.adUnitTag = supplier.adspotid;
        _bd_ad.publisherId = supplier.mediaid;
        _bd_ad.delegate = self;
        _bd_ad.presentAdViewController = _adspot.viewController;
        _bd_ad.timeout = supplier.timeout * 1.0 / 1000.0;
        
        CGRect adFrame = [UIApplication sharedApplication].keyWindow.bounds;
        if (_adspot.bottomLogoView) {
            adFrame.size.height -= _adspot.bottomLogoView.bounds.size.height;
        }
        _bd_ad.adSize = adFrame.size;
    }
    return self;
}

- (void)loadAd {
    [self.bd_ad load];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (BOOL)isAdValid {
    //return _bd_ad.isReady; 缓存时间太久了影响体验
    return YES;
}

- (void)showInWindow:(UIWindow *)window {
    // 设置logo
    if (_adspot.bottomLogoView) {
        _adspot.bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _adspot.bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _adspot.bottomLogoView.bounds.size.height);
        _adspot.bottomLogoView.hidden = YES;
        [window addSubview:_adspot.bottomLogoView];
    }
    [self.bd_ad showInContainerView:window];
}

#pragma mark: -BaiduMobAdSplashDelegate

- (void)splashAdLoadSuccess:(BaiduMobAdSplash *)splash {
    [self.adspot.manager setECPMIfNeeded:[[splash getECPMLevel] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)splashAdLoadFailCode:(NSString *)errCode
                     message:(NSString *)message
                    splashAd:(BaiduMobAdSplash *)nativeAd {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:[errCode integerValue] userInfo:@{@"desc": (message ?: @"")}];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)splashSuccessPresentScreen:(BaiduMobAdSplash *)splash {
    _adspot.bottomLogoView.hidden = NO;
}

- (void)splashDidExposure:(BaiduMobAdSplash *)splash {
    self.isAdExposed = YES;
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.bd_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashDidClicked:(BaiduMobAdSplash *)splash {
    // !!!百度开屏的曝光回调非常慢，往往会出现点击、关闭时还没曝光。
    if (!self.isAdExposed) {
        [self splashDidExposure:splash];
    }
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashDidDismissScreen:(BaiduMobAdSplash *)splash {
    [self removeAdViews];
    // !!!百度开屏的曝光回调非常慢，往往会出现点击、关闭时还没曝光。
    if (!self.isAdExposed) {
        [self splashDidExposure:splash];
    }
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)removeAdViews {
    [_adspot.bottomLogoView removeFromSuperview];
    [_bd_ad stop];
}

- (void)dealloc
{
    ADVLog(@"%s", __func__);
}

@end
