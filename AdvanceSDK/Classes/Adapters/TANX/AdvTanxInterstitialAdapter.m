//
//  AdvTanxInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxInterstitialAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceInterstitialCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvTanxInterstitialAdapter () <TXAdTableScreenManagerDelegate, AdvanceInterstitialCommonAdapter>
@property(nonatomic, strong) TXAdTableScreenManager *tanx_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation AdvTanxInterstitialAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _tanx_ad = [[TXAdTableScreenManager alloc] initWithPid:placementId];
    _tanx_ad.delegate = self;
}

- (void)adapter_loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getTableScreenAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable tableScreenModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.delegate interstitialAdapter_failedToLoadAdWithAdapterId:strongSelf.adapterId error:error];
        } else { // 获取广告成功
            strongSelf.adModel = tableScreenModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.delegate adapter_cacheAdapterIfNeeded:strongSelf adapterId:strongSelf.adapterId price:ecpm];
            [strongSelf.delegate interstitialAdapter_didLoadAdWithAdapterId:strongSelf.adapterId price:ecpm];
        }
    }];
}


- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [self.tanx_ad showAdOnRootViewController:rootViewController withModel:self.adModel];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

#pragma mark: -TXAdTableScreenManagerDelegate
- (void)onAdShow:(TXAdModel *)model{
    [self.delegate interstitialAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)onAdClick:(TXAdModel *)model{
    [self.delegate interstitialAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)onAdClose:(TXAdModel *)model{
    [self.delegate interstitialAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)onAdRenderFail:(TXAdModel *)model withError:(NSError *)error {
    [self.delegate interstitialAdapter_failedToShowAdWithAdapterId:self.adapterId error:error];
}

- (void)dealloc {
    
}

@end
