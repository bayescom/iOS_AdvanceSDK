//
//  CsjSplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "CsjSplashAdapter.h"

#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif

#import "AdvanceSplash.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface CsjSplashAdapter ()  <BUSplashAdDelegate, AdvanceAdapter>

@property (nonatomic, strong) BUSplashAd *csj_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) UIImageView *imgV;

@end

@implementation CsjSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect adFrame = [UIApplication sharedApplication].keyWindow.bounds;
        // 设置logo
        if (_adspot.logoImage && _adspot.showLogoRequire) {
            
            NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
        }
        _csj_ad = [[BUSplashAd alloc] initWithSlotID:_supplier.adspotid adSize:adFrame.size];
        _csj_ad.delegate = self;
        _csj_ad.tolerateTimeout = _supplier.timeout * 1.0 / 1000.0;
    }
    return self;
}

- (void)loadAd {
    [self.csj_ad loadAdData];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingSplashADWithSpotId:)]) {
        [self.delegate didFinishLoadingSplashADWithSpotId:self.adspot.adspotid];
    }
}

- (void)showInWindow:(UIWindow *)window {
    
    if (window && window.rootViewController) {
        [_csj_ad showSplashViewInRootViewController:window.rootViewController];
    }

    if (_adspot.showLogoRequire) {
        // 添加Logo
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
        _imgV.userInteractionEnabled = YES;
        _imgV.image = _adspot.logoImage;
        [_csj_ad.splashRootViewController.view addSubview:_imgV];
    }
}

// MARK: ======================= BUSplashAdDelegate =======================

- (void)splashAdLoadSuccess:(nonnull BUSplashAd *)splashAd {
    NSDictionary *ext = splashAd.mediaExt;
    [self.adspot.manager setECPMIfNeeded:[ext[@"price"] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)splashAdLoadFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
}

- (void)splashAdRenderSuccess:(BUSplashAd *)splashAd {
    
}

- (void)splashAdRenderFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)splashAdWillShow:(nonnull BUSplashAd *)splashAd {

}

- (void)splashAdDidShow:(nonnull BUSplashAd *)splashAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidShowForSpotId:extra:)] && self.csj_ad) {
        [self.delegate splashDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdDidClick:(nonnull BUSplashAd *)splashAd {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(splashDidClickForSpotId:extra:)]) {
        [self.delegate splashDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)splashAdDidClose:(nonnull BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    [self csjAdDidClose];
}

- (void)splashVideoAdDidPlayFinish:(nonnull BUSplashAd *)splashAd didFailWithError:(NSError *)error {
    
}

- (void)splashAdViewControllerDidClose:(nonnull BUSplashAd *)splashAd {
    
}


- (void)splashDidCloseOtherController:(nonnull BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {
    
}


- (void)csjAdDidClose {
    if ([self.delegate respondsToSelector:@selector(splashDidCloseForSpotId:extra:)]) {
        [self.delegate splashDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
    [self.csj_ad removeSplashView];
    self.csj_ad = nil;
    [self.imgV removeFromSuperview];
    self.imgV = nil;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

@end
