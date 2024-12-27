//
//  TanxNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "TanxNativeExpressAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceNativeExpress.h"
#import "AdvLog.h"
#import "AdvanceNativeExpressAd.h"
#import "AdvanceAdapter.h"
#import "NSArray+Adv.h"

@interface TanxNativeExpressAdapter () <TXAdFeedManagerDelegate, AdvanceAdapter>
@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, weak) AdvanceNativeExpress *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) NSArray *adModels;
@property (nonatomic, strong) NSMutableArray<__kindof AdvanceNativeExpressAd *> *nativeAds;

@end

@implementation TanxNativeExpressAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
        slotModel.pid = _supplier.adspotid;
        slotModel.showAdFeedBackView = NO;
        _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
        _tanx_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeTemplate adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        if (error) { // 获取广告失败
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:weakSelf.supplier error:error];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdFailed];
            
        } else { // 获取广告成功
            self.adModels = viewModelArray;
            TXAdModel *adModel = viewModelArray.firstObject;
            NSInteger ecpm = adModel.bid.bidPrice.integerValue;
            if (ecpm > 0) {
                [self.tanx_ad uploadBidding:adModel result:YES];
            }
            
            self.nativeAds = [NSMutableArray array];
            for (TXAdModel *model in viewModelArray) {
                AdvanceNativeExpressAd *TT = [[AdvanceNativeExpressAd alloc] init];
                TT.tanxAdModel = model;
                TT.identifier = self.supplier.identifier;
                [self.nativeAds addObject:TT];
            }
            
            [weakSelf.adspot.manager setECPMIfNeeded:ecpm supplier:weakSelf.supplier];
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:weakSelf.supplier error:nil];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdSuccess];
        }
    }];
}

- (void)winnerAdapterToShowAd {
    /// 广告加载成功回调
    if ([_delegate respondsToSelector:@selector(didFinishLoadingNativeExpressAds:spotId:)]) {
        [_delegate didFinishLoadingNativeExpressAds:self.nativeAds spotId:self.adspot.adspotid];
    }
    
    /// 渲染广告
    if (!_adspot.isGroMoreADN) {
        [self renderNativeAdView];
    }
}

/// 渲染广告
- (void)renderNativeAdView {
    
    TXAdFeedTemplateConfig *config = [[TXAdFeedTemplateConfig alloc] init];
    config.templateWidth = _adspot.adSize.width - 2 * 15.0;
    NSArray<TXAdFeedModule *> *feedModules = [self.tanx_ad renderFeedTemplateWithModel:self.adModels config:config];
    
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdModel:self.adModels.firstObject];
    if (feedModules.count) { /// render success
        if (nativeAd) {
            nativeAd.expressView = feedModules.firstObject.view;
            if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccess:spotId:extra:)]) {
                [_delegate nativeExpressAdViewRenderSuccess:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
            }
        }
    } else { /// render fail
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:nil];
        if (nativeAd) {
            if ([_delegate respondsToSelector:@selector(nativeExpressAdViewRenderFail:spotId:extra:)]) {
                [_delegate nativeExpressAdViewRenderFail:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
            }
        }
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark: -TXAdFeedManagerDelegate
/// ❌❌ 当feedModules获取为空时，还是会进入渲染成功回调
- (void)onAdRenderSuccess:(TXAdModel *)model {
    
}

- (void)onAdExposing:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdModel:model];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didShowNativeExpressAd:spotId:extra:)]) {
            [_delegate didShowNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)onAdClose:(TXAdModel *)model {
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdModel:model];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didCloseNativeExpressAd:spotId:extra:)]) {
            [_delegate didCloseNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (void)onAdClickDislikeOptions:(TXAdModel *)model index:(NSInteger)index {
    
}

/// 广告点击
- (void)onAdClick:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdModel:model];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

/// 广告滑动跳转
- (void)onAdSliding:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    AdvanceNativeExpressAd *nativeAd = [self getNativeExpressAdWithAdModel:model];
    if (nativeAd) {
        if ([_delegate respondsToSelector:@selector(didClickNativeExpressAd:spotId:extra:)]) {
            [_delegate didClickNativeExpressAd:nativeAd spotId:self.adspot.adspotid extra:self.adspot.ext];
        }
    }
}

- (AdvanceNativeExpressAd *)getNativeExpressAdWithAdModel:(TXAdModel *)adModel {
    for (NSInteger i = 0; i < self.nativeAds.count; i++) {
        AdvanceNativeExpressAd *temp = self.nativeAds[i];
        if (temp.tanxAdModel == adModel) {
            return temp;
        }
    }
    return nil;
}

@end
