//
//  GdtSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Gdt. All rights reserved.
//

#import "GdtSplashAdapter.h"

#if __has_include(<GDTSplashAd.h>)
#import <GDTSplashAd.h>
#else
#import "GDTSplashAd.h"
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "AdvanceAdapter.h"

@interface GdtSplashAdapter () <GDTSplashAdDelegate, AdvanceAdapter>
@property (nonatomic, strong) GDTSplashAd *gdt_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@property (nonatomic, assign) NSInteger isGMBidding;

@end

@implementation GdtSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTSplashAd alloc] initWithPlacementId:_supplier.adspotid];
        _gdt_ad.delegate = self;
        _gdt_ad.fetchDelay = _supplier.timeout * 1.0 / 1000.0;
    }
    return self;
}

- (void)loadAd {
    _adspot.viewController.modalPresentationStyle = 0;
    [_gdt_ad loadAd];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (void)gmShowAd {
    [self showAdAction];
}

- (void)showAd {
    NSNumber *isGMBidding = ((NSNumber * (*)(id, SEL))objc_msgSend)((id)self.adspot, @selector(isGMBidding));

    self.isGMBidding = isGMBidding.integerValue;
    if (isGMBidding.integerValue == 1) {
        return;
    }
    [self showAdAction];
}
- (void)showAdAction {
    // 设置logo
    UIImageView *imgV;
    if (_adspot.logoImage) {
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, real_w, real_h)];
        imgV.userInteractionEnabled = YES;
        imgV.image = _adspot.logoImage;
    }
    
    if ([self.gdt_ad isAdValid]) {
        [_gdt_ad showAdInWindow:_adspot.viewController.view.window withBottomView:_adspot.showLogoRequire?imgV:nil skipView:nil];
    }
}

- (void)showInWindow:(UIWindow *)window {
    // 设置logo
    UIImageView *imgV;
    if (_adspot.logoImage) {
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, real_w, real_h)];
        imgV.userInteractionEnabled = YES;
        imgV.image = _adspot.logoImage;
    }
   
    if ([self.gdt_ad isAdValid]) {
        [_gdt_ad showAdInWindow:window withBottomView:imgV skipView:nil];
    }
}

// MARK: ======================= GDTSplashAdDelegate =======================

- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    [self.adspot.manager setECPMIfNeeded:splashAd.eCPM supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.gdt_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdLifeTime:(NSUInteger)time {
    
    // 当GMBidding的时候 会有一个splashAdClosed 不执行的bug 所以需要用这个逻辑来触发 splashDidCloseForSpotId
    if (self.isGMBidding == 0) {
        return;
    }
    if (time <= 0 && [self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}


- (void)dealloc {
    ADVLog(@"%s %@", __func__, self);
}
@end
