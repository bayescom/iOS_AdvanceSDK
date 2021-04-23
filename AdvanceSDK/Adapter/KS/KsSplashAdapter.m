//
//  KsSplashAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/20.
//

#import "KsSplashAdapter.h"

#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
#import "KSAdSDK.h"
#endif

#import "AdvanceSplash.h"
#import "UIApplication+Adv.h"
#import "AdvLog.h"
#define WeakSelf(type) __weak typeof(type) weak##type = type;
#define StrongSelf(type) __strong typeof(weak##type) strong##type = weak##type;

@interface KsSplashAdapter ()<KSSplashAdViewDelegate>
@property (nonatomic, weak) AdvanceSplash *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;

// 剩余时间，用来判断用户是点击跳过，还是正常倒计时结束
@property (nonatomic, assign) NSUInteger leftTime;
// 是否点击了
@property (nonatomic, assign) BOOL isClick;
@property (nonatomic, strong) KSSplashAdView *ks_ad;


@end

@implementation KsSplashAdapter
- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(AdvanceSplash *)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _leftTime = 5;  // 默认5s
        _ks_ad = [[KSSplashAdView alloc] initWithPosId:_supplier.adspotid];
    }
    return self;
}

- (void)loadAd {

    
    ADVLog(@"加载快手 supplier: %@", _supplier);

    if (_supplier.state == AdvanceSdkSupplierStateSuccess) {// 并行请求保存的状态 再次轮到该渠道加载的时候 直接show
        ADVLog(@"快手 成功");
        [self showAd];
    } else if (_supplier.state == AdvanceSdkSupplierStateFailed) { //失败的话直接对外抛出回调
        ADVLog(@"快手 失败 %@", _supplier);
        [self.adspot loadNextSupplierIfHas];
        [self deallocAdapter];
    } else if (_supplier.state == AdvanceSdkSupplierStateInPull) { // 正在请求广告时 什么都不用做等待就行
        ADVLog(@"快手 正在加载中");
    } else {
        ADVLog(@"快手 load ad %@", _supplier.adspotid);
        _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
        NSInteger timeout = 5;
        if (self.adspot.timeout) {
            if (self.adspot.timeout > 500) {
                timeout = self.adspot.timeout / 1000.0;
            }
        }

        _ks_ad.delegate = self;
        _ks_ad.needShowMiniWindow = NO;
        _ks_ad.rootViewController = _adspot.viewController;
        _ks_ad.timeoutInterval = timeout;
        [_ks_ad loadAdData];
    }

}

- (void)deallocAdapter {
//    _gdt_ad = nil;
    if (self.ks_ad) {
        [self.ks_ad removeFromSuperview];
        self.ks_ad = nil;
    }
}


/**
 * splash ad request done
 */
- (void)ksad_splashAdDidLoad:(KSSplashAdView *)splashAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    [self showAd];

}
/**
 * splash ad material load, ready to display
 */
- (void)ksad_splashAdContentDidLoad:(KSSplashAdView *)splashAdView {
    
}
/**
 * splash ad (material) failed to load
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateFailed;
        return;
    }
    [self deallocAdapter];
}
/**
 * splash ad did visible
 */
- (void)ksad_splashAdDidVisible:(KSSplashAdView *)splashAdView {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}
/**
 * splash ad video begin play
 * for video ad only
 */
- (void)ksad_splashAdVideoDidBeginPlay:(KSSplashAdView *)splashAdView {

}
/**
 * splash ad clicked
 * @param inMiniWindow whether click in mini window
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didClick:(BOOL)inMiniWindow {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}
/**
 * splash ad will zoom out, frame can be assigned
 * for video ad only
 * @param frame target frame
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView willZoomTo:(inout CGRect *)frame {
    
}
/**
 * splash ad zoomout view will move to frame
 * @param frame target frame
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView willMoveTo:(inout CGRect *)frame {
    
}
/**
 * splash ad skipped
 * @param showDuration  splash show duration (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAd:(KSSplashAdView *)splashAdView didSkip:(NSTimeInterval)showDuration {
    NSLog(@"----%@", NSStringFromSelector(_cmd));
    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
        [self.delegate advanceSplashOnAdSkipClicked];
    }
    [self deallocAdapter];
}
/**
 * splash ad close conversion viewcontroller (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidCloseConversionVC:(KSSplashAdView *)splashAdView interactionType:(KSAdInteractionType)interactType {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
    [self deallocAdapter];

}

/**
 * splash ad play finished & auto dismiss (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidAutoDismiss:(KSSplashAdView *)splashAdView {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
    [self deallocAdapter];

}
/**
 * splash ad close by user (zoom out mode) (no subsequent callbacks, remove & release KSSplashAdView here)
 */
- (void)ksad_splashAdDidClose:(KSSplashAdView *)splashAdView {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
    [self deallocAdapter];

}
















//- (void)checkAction {
//    NSInteger timeout = 5;
//    if (self.adspot.timeout) {
//        if (self.adspot.timeout > 500) {
//            timeout = self.adspot.timeout / 1000.0;
//        }
//    }
//
//    WeakSelf(self);
//    [KSAdSplashManager checkSplashWithTimeoutv2:timeout completion:^(KSAdSplashViewController * _Nullable splashViewController, NSError * _Nullable error) {
//        StrongSelf(self);
//        NSLog(@"kssplashViewController %@   error:%@", splashViewController, error);
//        [strongself checkResultWith:splashViewController error:error];
//    }];
//}
//
//- (void)checkResultWith:(KSAdSplashViewController *)splashViewController error:(NSError *)error {
//    if (splashViewController) {
//        // 请求数据成功
//        [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
//        if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
//            [self.delegate advanceUnifiedViewDidLoad];
//        }
//        self.vc = splashViewController;
//        if (_supplier.isParallel == YES) {
//            _supplier.state = AdvanceSdkSupplierStateSuccess;
//            return;
//        }
//        [self showAd];
//    }
//
//    if (error) {
//        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
//        if (_supplier.isParallel == YES) {
//            _supplier.state = AdvanceSdkSupplierStateFailed;
//        }
//    }
//}

- (void)showAd {
    if (!_ks_ad) {
        return;
    }
    _ks_ad.frame = [UIScreen mainScreen].bounds;
    [_adspot.viewController.view addSubview:_ks_ad];
}

//- (void)ksad_splashAdDismiss:(BOOL)converted {
//    //convert为YES时需要直接隐藏掉splash，防止影响后续转化页面展示
//    WeakSelf(self)
//    [self.vc dismissViewControllerAnimated:!converted completion:^{
//        StrongSelf(self);
//        if ([strongself.delegate respondsToSelector:@selector(advanceDidClose)]) {
//            [strongself.delegate advanceDidClose];
//        }
//    }];
//
//}
//
//- (void)ksad_splashAdClicked {
//    NSLog(@"----%@", NSStringFromSelector(_cmd));
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
//    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
//        [self.delegate advanceClicked];
//    }
//}
//
//- (void)ksad_splashAdDidShow {
//    NSLog(@"----%@", NSStringFromSelector(_cmd));
//    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
//    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
//        [self.delegate advanceExposured];
//    }
//}
//
//- (void)ksad_splashAdTimeOver {
//    NSLog(@"----%@", NSStringFromSelector(_cmd));
//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdCountdownToZero)]) {
//        [self.delegate advanceSplashOnAdCountdownToZero];
//    }
//
//}
//
//- (void)ksad_splashAdVideoDidSkipped:(NSTimeInterval)playDuration {
//    NSLog(@"----%@", NSStringFromSelector(_cmd));
//    if ([self.delegate respondsToSelector:@selector(advanceSplashOnAdSkipClicked)]) {
//        [self.delegate advanceSplashOnAdSkipClicked];
//    }
//}
//
//- (void)ksad_splashAdVideoDidStartPlay {
//    NSLog(@"----%@", NSStringFromSelector(_cmd));
//}
//
//- (void)ksad_splashAdVideoFailedToPlay:(NSError *)error {
//    NSLog(@"----%@, %@", NSStringFromSelector(_cmd), error);
//}
//
//- (UIViewController *)ksad_splashAdConversionRootVC {
//    return [UIApplication sharedApplication].adv_getCurrentWindow.rootViewController;
//}
//

@end
