//
//  BdBannerAdapter.m
//  AdvanceSDK
//
//  Created by MS on 2021/5/28.
//

#import "BdBannerAdapter.h"
#if __has_include(<BaiduMobAdSDK/BaiduMobAdView.h>)
#import <BaiduMobAdSDK/BaiduMobAdView.h>
#else
#import "BaiduMobAdSDK/BaiduMobAdView.h"
#endif
#import "AdvanceBanner.h"
#import "AdvLog.h"

@interface BdBannerAdapter ()<BaiduMobAdViewDelegate>
@property (nonatomic, strong) BaiduMobAdView *bd_ad;
@property (nonatomic, weak) AdvanceBanner *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;


@property (nonatomic, assign) BOOL isBided;
@property (nonatomic, assign) BOOL isDidload;
@property (nonatomic, assign) BOOL isClose;

@end
@implementation BdBannerAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        CGRect rect = CGRectMake(0, 0, _adspot.adContainer.frame.size.width, _adspot.adContainer.frame.size.height);
        _bd_ad = [[BaiduMobAdView alloc] init];
        _bd_ad.AdType = BaiduMobAdViewTypeBanner;
        _bd_ad.delegate = self;
        _bd_ad.AdUnitTag = _supplier.adspotid;
        _bd_ad.frame = rect;
    }
    return self;
}


- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载百度 supplier: %@", _supplier);
        
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_bd_ad start];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"百度加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"百度 成功");
    if (_isDidload) {
        return;
    }
    [self unifiedDelegate];
    
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"百度 失败");
    [_adspot loadNextSupplierIfHas];
    [self deallocAdapter];
}


- (void)loadAd {
    [super loadAd];
}



- (NSString *)publisherId {
    return  _supplier.mediaid; //@"your_own_app_id";
}

- (void)willDisplayAd:(BaiduMobAdView *)adview {
    _supplier.state = AdvanceSdkSupplierStateSuccess;
    if (!_isBided) {// 只让bidding触发一次即可
        [self.adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        _isBided = YES;
    }
    [self.adspot reportWithType:AdvanceSdkSupplierRepoSucceeded supplier:_supplier error:nil];
    if (_supplier.isParallel == YES) {
        return;
    }
    [self unifiedDelegate];
    _isDidload = YES;
}

- (void)failedDisplayAd:(BaiduMobFailReason)reason {
    NSError *error = [[NSError alloc]initWithDomain:@"BDAdErrorDomain" code:1000020 + reason userInfo:@{@"desc":@"百度广告展现错误"}];
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFaileded  supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
//    NSLog(@"========>>>>>>>> %ld %@", (long)_supplier.priority, error);
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        
        return;
    } else { //
        [self deallocAdapter];
    }
}

- (void)didAdImpressed {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceExposured)]) {
        [self.delegate advanceExposured];
    }
}

- (void)didAdClicked {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(advanceClicked)]) {
        [self.delegate advanceClicked];
    }
}

//点击关闭的时候移除广告
- (void)didAdClose {
//    [sharedAdView removeFromSuperview];
    
    [self closeDelegate];
}



- (void)unifiedDelegate {
    if ([self.delegate respondsToSelector:@selector(advanceUnifiedViewDidLoad)]) {
        [self.delegate advanceUnifiedViewDidLoad];
    }
    //    [self showAd];
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


- (void)didDismissLandingPage {
    
}
@end
