//
//  MercurySplashAdapter.m
//  AdvanceSDKExample
//
//  Created by CherryKing on 2020/4/8.
//  Copyright © 2020 Mercury. All rights reserved.
//

#import "MercurySplashAdapter.h"

#if __has_include(<MercurySDK/MercurySplashAd.h>)
#import <MercurySDK/MercurySplashAd.h>
#else
#import "MercurySplashAd.h"
#endif

#import "AdvSupplierModel.h"
#import "AdvanceSplash.h"
#import "AdvLog.h"

#import <objc/runtime.h>
#import <objc/message.h>
#import <MercurySDK/MercurySDK.h>
@interface MercurySplashAdapter () <MercurySplashAdDelegate>
@property (nonatomic, strong) MercurySplashAd *mercury_ad;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, assign) BOOL isCanch;
@property (nonatomic, assign) NSInteger isGMBidding;

@end

@implementation MercurySplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        [MercuryConfigManager openDebug:YES];
        _mercury_ad = [[MercurySplashAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
//        _mercury_ad.placeholderImage = _adspot.backgroundImage;
        _mercury_ad.logoImage = _adspot.logoImage;
        NSNumber *showLogoType = _adspot.extParameter[MercuryLogoShowTypeKey];
        NSNumber *blankGap = _adspot.extParameter[MercuryLogoShowBlankGapKey];

        
        if (showLogoType) {
            _mercury_ad.showType = (showLogoType.integerValue);
        } else {
            _mercury_ad.showType = MercurySplashAdAutoAdaptScreenWithLogoFirst;
        }

        _mercury_ad.blankGap = blankGap.integerValue;
        _mercury_ad.delegate = self;
        _mercury_ad.controller = _adspot.viewController;
    }
    return self;
}



- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载Mercury supplier: %@", _supplier);
    //        if (_adspot.showLogoRequire) {
    //            _mercury_ad.showType = MercurySplashAdAutoAdaptScreen;
    //        }
    if (_adspot.timeout) {
        if (_adspot.timeout > 500) {
            _mercury_ad.fetchDelay = _supplier.timeout / 1000.0;
        }
    }
    
    [_mercury_ad loadAd];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"Mercury加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"Mercury 成功");
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"Mercury 失败");
    [self.adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
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
//    [[UIApplication sharedApplication].keyWindow addSubview:_csj_ad];
//    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[_adspot performSelector:@selector(bgImgV)]];
        UIImageView *imgV;
        if (_adspot.showLogoRequire) {
            // 添加Logo
            NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
            imgV.userInteractionEnabled = YES;
            imgV.image = _adspot.logoImage;
        }
    
        [self.mercury_ad showAdInWindow:_adspot.viewController.view.window];

}


- (void)showInWindow:(UIWindow *)window {
    
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

- (void)deallocAdapter {
//    ADV_LEVEL_INFO_LOG(@"11===> %s %@", __func__, [NSThread currentThread]);
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self);
    if (self.mercury_ad) {
        self.delegate = nil;
        [_mercury_ad destory];
        _mercury_ad.delegate = nil;
        _mercury_ad = nil;
        
    }
}

// MARK: ======================= MercurySplashAdDelegate =======================
- (void)mercury_splashAdDidLoad:(MercurySplashAd *)splashAd {
    
}

- (void)mercury_materialDidLoad:(MercurySplashAd *)splashAd isFromCache:(BOOL)isFromCache {
    _supplier.supplierPrice = [splashAd getPrice];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];

    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];

}

- (void)mercury_splashAdExposured:(MercurySplashAd *)splashAd {

    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.mercury_ad) {

        [self.delegate advanceExposured];
    }
}

- (void)mercury_splashAdFailError:(nullable NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }

//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceSplashOnAdFailedWithSdkId:_supplier.identifier error:error];
//    }
}

- (void)mercury_splashAdClicked:(MercurySplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)mercury_splashAdLifeTime:(NSUInteger)time {
//    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
//        [self.delegate advanceSplashOnAdCountdownToZero];
//    }
    
    if (self.isGMBidding == 0) {
        return;
    }
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)mercury_splashAdSkipClicked:(MercurySplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

- (void)mercury_splashAdClosed:(MercurySplashAd *)splashAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}

- (void)unifiedDelegate {
    if (_isCanch) {
        return;
    }
    _isCanch = YES;
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
//    [self showAd];
}

@end
