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
@interface CsjSplashAdapter ()  <BUSplashAdDelegate>

@property (nonatomic, strong) BUSplashAdView *csj_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

@end

@implementation CsjSplashAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect adFrame = [UIApplication sharedApplication].keyWindow.bounds;
        // 设置logo
        if (_adspot.logoImage && _adspot.showLogoRequire) {
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            adFrame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-real_h);
        }
        _csj_ad = [[BUSplashAdView alloc] initWithSlotID:_supplier.adspotid frame:adFrame];

    }
    return self;
}

- (void)loadAd {
    
    if (self.adspot.timeout) {
        if (self.adspot.timeout > 500) {
            _csj_ad.tolerateTimeout = _adspot.timeout / 1000.0;
        }
    }

    _csj_ad.delegate = self;
    
    NSLog(@"加载穿山甲 supplier: %@ -- %ld", _supplier, (long)_supplier.priority);
    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"穿山甲 成功");
        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"穿山甲 失败");
        [self.adspot loadNextSupplierIfHas];
        [self deallocAdapter];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"穿山甲 正在加载中");
    } else {
        ADVLog(@"穿山甲 load ad");
        [self.csj_ad loadAdData];
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    }


/*
    // ABCDEFGH  ACF BE DH G
    
    // 按优先级排序确定执行顺序       // 并行 load       并行 load      并行 load         并行 load
             渠道A  · · · · · · · · 渠道C · · · · ·  渠道F · · · · · · · · · · · · · · · · · · · · · 未来更多
               ↓                     ↓               ↓
             渠道B  · · · · · · · · · · · · · · · · · · · · · · · · 渠道E · · · · · · · · · · · · · 未来更多
               ↓                     ↓               ↓               ↓
             渠道C  ← ← ← ← ← ← ← ← ←
               ↓                                     ↓               ↓
             渠道D  · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · · 渠道H · · · · 未来更多
               ↓                                     ↓               ↓                 ↓             ↓
             渠道E  ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←  ← ← ← ← ← ← ← ←
               ↓                                     ↓                                 ↓             ↓
             渠道F  ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
               ↓                                                                       ↓             ↓
             渠道G
               ↓                                                                       ↓             ↓
             渠道H  ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
               ↓                                                                                     ↓
            未来更多 ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ← ←
    

    
    // 每个渠道执行时的广告数据状态
    // 串行渠道 load和show一定是结合在一起的  所以成功 失败 请求中 一定是并行状态
    if (state == Success) { // 并行状态
        show
    } else if (state == Failed) { // 并行状态
        next
    } else if (state == loading) { // 并行状态
        go on
    } else { // 其他均为串行状态
        load and show
    }
*/
}

- (void)deallocAdapter {
    if (self.csj_ad) {
        NSLog(@"穿山甲 释放了");
        [self.csj_ad removeFromSuperview];
        self.csj_ad = nil;
    }
}

- (void)showAd {
    [[UIApplication sharedApplication].keyWindow addSubview:_csj_ad];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:[_adspot performSelector:@selector(bgImgV)]];
    
    _csj_ad.backgroundColor = [UIColor clearColor];
    _csj_ad.rootViewController = _adspot.viewController;
    
    if (_adspot.showLogoRequire) {
        // 添加Logo
        CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
        CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
        UIImageView *imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-real_h, real_w, real_h)];
        imgV.userInteractionEnabled = YES;
        imgV.image = _adspot.logoImage;
        if (imgV) {
            [_csj_ad addSubview:imgV];
        }
    }

}
// MARK: ======================= BUSplashAdDelegate =======================
/**
 This method is called when splash ad material loaded successfully.
 */
- (void)splashAdDidLoad:(BUSplashAdView *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    NSLog(@"穿山甲开屏拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    
    [self showAd];
}

/**
 This method is called when splash ad material failed to load.
 @param error : the reason of error
 */
- (void)splashAd:(BUSplashAdView *)splashAd didFailWithError:(NSError * _Nullable)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
//    NSLog(@"========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }

//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.adspotid error:error];
//    }
}

/**
 This method is called when splash ad slot will be showing.
 */
- (void)splashAdWillVisible:(BUSplashAdView *)splashAd {
    if (_supplier.isParallel) { // 如果是并行 先不要释放, 需要等到串行执行到这个渠道的时候才可以释放
        [self deallocAdapter];
    }

    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)] && self.csj_ad) {
        [self.delegate advanceExposured];
    }
}

/**
 This method is called when splash ad is clicked.
 */
- (void)splashAdDidClick:(BUSplashAdView *)splashAd {
    [self deallocAdapter];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

/**
 This method is called when splash ad is closed.
 */
- (void)splashAdDidClose:(BUSplashAdView *)splashAd {
    [_csj_ad removeFromSuperview];
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
//    _csj_ad = nil;
}

/**
 This method is called when spalashAd skip button  is clicked.
 */
- (void)splashAdDidClickSkip:(BUSplashAdView *)splashAd {
    [self deallocAdapter];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
}

/**
 This method is called when spalashAd countdown equals to zero
 */
- (void)splashAdCountdownToZero:(BUSplashAdView *)splashAd {
    [self deallocAdapter];
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
}

- (void)splashAdDidCloseOtherController:(BUSplashAdView *)splashAd interactionType:(BUInteractionType)interactionType {
    [self deallocAdapter];
}

@end
