//
//  KsInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/4/25.
//

#import "KsInterstitialAdapter.h"
#if __has_include(<KSAdSDK/KSAdSDK.h>)
#import <KSAdSDK/KSAdSDK.h>
#else
//#import "KSAdSDK.h"
#endif

#import "AdvanceInterstitial.h"
#import "AdvLog.h"

@interface KsInterstitialAdapter ()<KSInterstitialAdDelegate>
@property (nonatomic, strong) KSInterstitialAd *ks_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, assign) BOOL isDidLoad;
@property (nonatomic, assign) BOOL isCanch;

@end
 
@implementation KsInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _isDidLoad = NO;
        _ks_ad = [[KSInterstitialAd alloc] initWithPosId:_supplier.adspotid];
        _ks_ad.videoSoundEnabled = !_adspot.muted;
    }
    return self;
}


- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载快手 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    _ks_ad.delegate = self;
    [_ks_ad loadAdData];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"快手加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"快手 成功");
    
    [self unifiedDelegate];
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"快手 失败");
    [self.adspot loadNextSupplierIfHas];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (_ks_ad) {
        _ks_ad.delegate = nil;
        _ks_ad = nil;
    }
}

- (void)dealloc
{
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}

- (void)showAd {
    if (!_ks_ad) {
        return;
    }
    [_ks_ad showFromViewController:_adspot.viewController];
}


/**
 * interstitial ad data loaded
 */
- (void)ksad_interstitialAdDidLoad:(KSInterstitialAd *)interstitialAd {

}
/**
 * interstitial ad render success
 */
- (void)ksad_interstitialAdRenderSuccess:(KSInterstitialAd *)interstitialAd {
    _supplier.supplierPrice = interstitialAd.ecpm;
    [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    _isDidLoad = YES;
//    ADVLog(@"快手插屏视频拉取成功");
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];

}
/**
 * interstitial ad load or render failed
 */
- (void)ksad_interstitialAdRenderFail:(KSInterstitialAd *)interstitialAd error:(NSError * _Nullable)error {
    if (_isDidLoad) {// 如果已经load 报错 为renderFail
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];

    } else {// 如果没有load 报错 则为 loadfail
        [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded supplier:_supplier error:error];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) { // 并行不释放 只上报
            return;
        }
    }
}
/**
 * interstitial ad will visible
 */
- (void)ksad_interstitialAdWillVisible:(KSInterstitialAd *)interstitialAd {
    
}
/**
 * interstitial ad did visible
 */
- (void)ksad_interstitialAdDidVisible:(KSInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}
/**
 * interstitial ad did skip (for video only)
 * @param playDuration played duration
 */
- (void)ksad_interstitialAd:(KSInterstitialAd *)interstitialAd didSkip:(NSTimeInterval)playDuration {
    
}
/**
 * interstitial ad did click
 */
- (void)ksad_interstitialAdDidClick:(KSInterstitialAd *)interstitialAd {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}
/**
 * interstitial ad will close
 */
- (void)ksad_interstitialAdWillClose:(KSInterstitialAd *)interstitialAd {
    
}
/**
 * interstitial ad did close
 */
- (void)ksad_interstitialAdDidClose:(KSInterstitialAd *)interstitialAd {
    if ([self.delegate respondsToSelector:@selector(advanceDidClose)]) {
        [self.delegate advanceDidClose];
    }
}
/**
 * interstitial ad did close other controller
 */
- (void)ksad_interstitialAdDidCloseOtherController:(KSInterstitialAd *)interstitialAd interactionType:(KSAdInteractionType)interactionType {
    
}

- (void)unifiedDelegate {
    if (_isCanch) {
        return;
    }
    _isCanch = YES;
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
}


@end
