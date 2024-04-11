//
//  TanxInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "TanxInterstitialAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceInterstitial.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface TanxInterstitialAdapter () <TXAdTableScreenManagerDelegate, AdvanceAdapter>
@property(nonatomic, strong) TXAdTableScreenManager *tanx_ad;
@property (nonatomic, weak) AdvanceInterstitial *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation TanxInterstitialAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _tanx_ad = [[TXAdTableScreenManager alloc] initWithPid:_supplier.adspotid];
        _tanx_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getTableScreenAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable tableScreenModels, NSError * _Nullable error) {
        if (error) { // 获取广告失败
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:weakSelf.supplier error:error];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdFailed];
            
        } else { // 获取广告成功
            self.adModel = tableScreenModels.firstObject;
            NSInteger ecpm = self.adModel.bid.bidPrice.integerValue;
            if (ecpm > 0) {
                [self.tanx_ad uploadBidding:self.adModel result:YES];
            }
            [weakSelf.adspot.manager setECPMIfNeeded:ecpm supplier:weakSelf.supplier];
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:weakSelf.supplier error:nil];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdSuccess];
        }
    }];
}

- (void)showAd {
    [self.tanx_ad showAdOnRootViewController:self.adspot.viewController withModel:self.adModel];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingInterstitialADWithSpotId:)]) {
        [self.delegate didFinishLoadingInterstitialADWithSpotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark: -TXAdTableScreenManagerDelegate

- (void)onAdShow:(TXAdModel *)model{
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidShowForSpotId:extra:)]) {
        [self.delegate interstitialDidShowForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdClick:(TXAdModel *)model{
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(interstitialDidClickForSpotId:extra:)]) {
        [self.delegate interstitialDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdClose:(TXAdModel *)model{
    if ([self.delegate respondsToSelector:@selector(interstitialDidCloseForSpotId:extra:)]) {
        [self.delegate interstitialDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdRenderFail:(TXAdModel *)model withError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

@end
