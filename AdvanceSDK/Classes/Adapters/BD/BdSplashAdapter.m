//
//  BdSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/24.
//

#import "BdSplashAdapter.h"
#import <BaiduMobAdSDK/BaiduMobAdSplash.h>
#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface BdSplashAdapter ()<BaiduMobAdSplashDelegate, AdvanceAdapter>

@property (nonatomic, strong) BaiduMobAdSplash *bd_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) UIImageView *imgV;
@property (nonatomic, assign) BOOL isAdExposed;

@end

@implementation BdSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _bd_ad = [[BaiduMobAdSplash alloc] init];
        _bd_ad.AdUnitTag = supplier.adspotid;
        _bd_ad.delegate = self;
        _bd_ad.timeout = supplier.timeout * 1.0 / 1000.0;
        
        CGRect adFrame = [UIApplication sharedApplication].keyWindow.bounds;
        if (_adspot.logoImage && _adspot.showLogoRequire) {
            NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
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

- (void)showInWindow:(UIWindow *)window {
    // 设置logo
    if (_adspot.logoImage && _adspot.showLogoRequire) {
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        self.imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, UIScreen.mainScreen.bounds.size.height - real_h, real_w, real_h)];
        self.imgV.userInteractionEnabled = YES;
        self.imgV.image = _adspot.logoImage;
        self.imgV.hidden = YES;
        [window addSubview:self.imgV];
    }
    [self.bd_ad showInContainerView:window];
}

#pragma mark: -BaiduMobAdSplashDelegate

- (NSString *)publisherId {
    return _supplier.mediaid;
}

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
    self.imgV.hidden = NO;
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
    [self.imgV removeFromSuperview];
    [_bd_ad stop];
}

- (void)dealloc
{
    ADVLog(@"%s", __func__);
}

@end
