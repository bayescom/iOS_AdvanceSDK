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

@interface GdtSplashAdapter () <GDTSplashAdDelegate>
@property (nonatomic, strong) GDTSplashAd *gdt_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;

@end

@implementation GdtSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
    }
    return self;
}

- (void)loadAd {
    _gdt_ad = [[GDTSplashAd alloc] initWithPlacementId:_supplier.adspotid];

    _gdt_ad.delegate = self;
    if (self.adspot.timeout) {
        if (self.adspot.timeout > 500) {
            _gdt_ad.fetchDelay = _adspot.timeout / 1000.0;
        }
    }
    _adspot.viewController.modalPresentationStyle = 0;
    // 设置 backgroundImage
    _gdt_ad.backgroundImage = _adspot.backgroundImage;
    [_gdt_ad loadAd];
}

// MARK: ======================= GDTSplashAdDelegate =======================
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdReceived)]) {
        [self.delegate advanceSplashOnAdReceived];
    }
}

- (void)deallocAdapter {
    _gdt_ad = nil;
}

- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    // 设置logo
    UIImageView *imgV;
    if (_adspot.logoImage) {
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, real_w, real_h)];
        imgV.userInteractionEnabled = YES;
        imgV.image = _adspot.logoImage;
    }
    [_gdt_ad showAdInWindow:[UIApplication sharedApplication].adv_getCurrentWindow withBottomView:_adspot.showLogoRequire?imgV:nil skipView:nil];
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded error:error];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.adspotid error:error];
    }
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
    _isClick = YES;
}

- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    // 如果时间大于0 且不是因为点击触发的，则认为是点击了跳过
    if (_leftTime > 0 && !_isClick) {
        if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
            [self.delegate advanceSplashOnAdSkipClicked];
        }
    }
}

- (void)splashAdLifeTime:(NSUInteger)time {
    _leftTime = time;
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

@end
