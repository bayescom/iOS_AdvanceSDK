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

@interface GdtSplashAdapter () <GDTSplashAdDelegate>
@property (nonatomic, strong) GDTSplashAd *gdt_ad;
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, assign) BOOL isCanch;
@property (nonatomic, assign) NSInteger isGMBidding;

@end

@implementation GdtSplashAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
        _gdt_ad = [[GDTSplashAd alloc] initWithPlacementId:_supplier.adspotid];
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载广点通 supplier: %@", _supplier);
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        
        if (!_gdt_ad) {
            return;
        }
        _adspot.viewController.modalPresentationStyle = 0;
        // 设置 backgroundImage
        _gdt_ad.backgroundImage = _adspot.backgroundImage;
        _gdt_ad.delegate = self;
        
        NSInteger parallel_timeout = _supplier.timeout;
        if (parallel_timeout == 0) {
            parallel_timeout = 3000;
        }
        _gdt_ad.fetchDelay = parallel_timeout / 1000.0;

        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        [_gdt_ad loadAd];
    });
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"广点通加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"广点通 成功");
    [self unifiedDelegate];
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"广点通 失败");
    [self.adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

// MARK: ======================= GDTSplashAdDelegate =======================
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
}

- (void)deallocAdapter {
    _gdt_ad = nil;
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
    __weak typeof(self) _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(_self) self = _self;
        UIImageView *imgV;
        if (_adspot.logoImage) {
            CGFloat real_w = [UIScreen mainScreen].bounds.size.width;
            CGFloat real_h = _adspot.logoImage.size.height*(real_w/_adspot.logoImage.size.width);
            imgV = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, real_w, real_h)];
            imgV.userInteractionEnabled = YES;
            imgV.image = _adspot.logoImage;
        }
        if (self.gdt_ad) {
            
            if ([self.gdt_ad isAdValid]) {
                [_gdt_ad showAdInWindow:[UIApplication sharedApplication].adv_getCurrentWindow withBottomView:_adspot.showLogoRequire?imgV:nil skipView:nil];
            } else {
                
            }
        }
    });
}

- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
//    NSLog(@"广点通开屏拉取成功 %@ %d",self.gdt_ad ,[self.gdt_ad isAdValid]);
    _supplier.supplierPrice = splashAd.eCPM;
    _supplier.supplierPrice = 1000;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    NSLog(@"广点通开屏拉取成功 %d",splashAd.eCPM);

    if (_supplier.isParallel == YES) {
//        NSLog(@"修改状态: %@", _supplier);
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    [self unifiedDelegate];
}

- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if (self.delegate && [self.delegate respondsToSelector:@selector(advanceExposured)] && self.gdt_ad) {
        [self.delegate advanceExposured];
    }
}

- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }

//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdFailedWithSdkId:error:)]) {
//        [self.delegate advanceSplashOnAdFailedWithSdkId:_adspot.adspotid error:error];
//    }
}

- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
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
        if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
            [self.delegate advanceDidClose];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
            [self.delegate advanceDidClose];
        }
    }
}

- (void)splashAdLifeTime:(NSUInteger)time {
    _leftTime = time;
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
        [self.delegate advanceSplashOnAdCountdownToZero];
    }
    
    // 当GMBidding的时候 会有一个splashAdClosed 不执行的bug 所以需要用这个逻辑来触发 advanceDidClose
    if (self.isGMBidding == 0) {
        return;
    }
    if (time <= 0 && [self.delegate respondsToSelector:@selector(advanceDidClose)]) {
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
    [self showAd];
}


@end
