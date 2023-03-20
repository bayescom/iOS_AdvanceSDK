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
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#import <objc/runtime.h>
#import <objc/message.h>

@interface CsjSplashAdapter ()  <BUSplashAdDelegate>

@property (nonatomic, strong) BUSplashAd *csj_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) UIImageView *imgV;

@property (nonatomic, assign) BOOL isCanch;
@property (nonatomic, assign) BOOL isClose;

@end

@implementation CsjSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
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
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
    
    NSInteger parallel_timeout = _supplier.timeout;
    if (parallel_timeout == 0) {
        parallel_timeout = 3000;
    }
    _csj_ad.tolerateTimeout = parallel_timeout / 1000.0;
    
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [self.csj_ad loadAdData];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [_adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
    
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s %@", __func__, self.csj_ad);
    
    //        ADV_LEVEL_INFO_LOG(@"%@", [NSThread currentThread]);
    if (_csj_ad) {
        //        NSLog(@"穿山甲 释放了");
        [_csj_ad removeSplashView];
        _csj_ad.delegate = nil;
        _csj_ad = nil;
        [self.imgV removeFromSuperview];
        self.imgV = nil;
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
    
    //        [[UIApplication sharedApplication].keyWindow addSubview:_csj_ad];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[_adspot performSelector:@selector(bgImgV)]];
    
    [_csj_ad showSplashViewInRootViewController:[UIApplication sharedApplication].adv_getCurrentWindow.rootViewController];
    
}
// MARK: ======================= BUSplashAdDelegate =======================



- (void)splashAdLoadSuccess:(nonnull BUSplashAd *)splashAd {
//    NSLog(@"11111111111");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
//    NSLog(@"穿山甲开屏拉取成功");
//    _supplier = nil;
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];
}

- (void)splashAdRenderSuccess:(nonnull BUSplashAd *)splashAd {
//    NSLog(@"2222222222");
    
    if (_adspot.showLogoRequire) {
        // 添加Logo
        NSAssert(_adspot.logoImage != nil, @"showLogoRequire = YES时, 必须设置logoImage");
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        _imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
        _imgV.userInteractionEnabled = YES;
        _imgV.image = _adspot.logoImage;
        if (_imgV) {
            [_csj_ad.splashRootViewController.view addSubview:_imgV];
        }
    }
}


- (void)splashAdLoadFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    _supplier.state = AdvanceSdkSupplierStateFailed;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//    NSLog(@"========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }
}


- (void)splashAdRenderFail:(nonnull BUSplashAd *)splashAd error:(BUAdError * _Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
}

- (void)splashAdWillShow:(nonnull BUSplashAd *)splashAd {

}

- (void)splashAdDidShow:(nonnull BUSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.csj_ad) {
        [self.delegate advanceExposured];
    }
}

- (void)splashAdDidClick:(nonnull BUSplashAd *)splashAd {
//    [self deallocAdapter];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

- (void)splashAdDidClose:(nonnull BUSplashAd *)splashAd closeType:(BUSplashAdCloseType)closeType {
    
    if (closeType == BUSplashAdCloseType_CountdownToZero) {
//        if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
//            [self.delegate advanceSplashOnAdCountdownToZero];
//        }
    }
    
    if (closeType == BUSplashAdCloseType_ClickSkip) {
        if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
            [self.delegate advanceSplashOnAdSkipClicked];
        }
    }
    
    [self closeDelegate];
}

- (void)splashAdViewControllerDidClose:(BUSplashAd *)splashAd {
    [self closeDelegate];
}

- (void)splashDidCloseOtherController:(nonnull BUSplashAd *)splashAd interactionType:(BUInteractionType)interactionType {
    [self closeDelegate];
}

- (void)splashVideoAdDidPlayFinish:(nonnull BUSplashAd *)splashAd didFailWithError:(nonnull NSError *)error {
    
}


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

- (void)closeDelegate {
    if (_isClose) {
        return;
    }
    _isClose = YES;

    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];

    }
    [self deallocAdapter];

}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];

}

@end
