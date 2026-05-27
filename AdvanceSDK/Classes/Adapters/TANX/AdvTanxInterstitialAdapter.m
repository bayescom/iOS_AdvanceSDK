//
//  AdvTanxInterstitialAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxInterstitialAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvTanxInterstitialAdapter () <TXAdTableScreenManagerDelegate, AdvanceCommonInterstitialAdapter>

@property (nonatomic, weak) id<AdvanceCommonInterstitialAdapterBridge> bridge;
@property(nonatomic, strong) TXAdTableScreenManager *tanx_ad;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation AdvTanxInterstitialAdapter

- (void)adapter_setInterstitialBridge:(id<AdvanceCommonInterstitialAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _tanx_ad = [[TXAdTableScreenManager alloc] initWithPid:placementId];
    _tanx_ad.delegate = self;
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getTableScreenAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable tableScreenModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.bridge interstitial_failedToLoadAdWithAdapter:strongSelf error:error];
        } else { // 获取广告成功
            strongSelf.adModel = tableScreenModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.bridge interstitial_didLoadAdWithAdapter:strongSelf price:ecpm];
        }
    }];
}


- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [self.tanx_ad showAdOnRootViewController:rootViewController withModel:self.adModel];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_tanx_ad uploadBidding:_adModel result:YES];
    } else {
        [_tanx_ad uploadBidding:_adModel result:NO];
    }
}

#pragma mark: -TXAdTableScreenManagerDelegate
- (void)onAdShow:(TXAdModel *)model{
    [self.bridge interstitial_didAdExposuredWithAdapter:self];
}

- (void)onAdClick:(TXAdModel *)model{
    [self.bridge interstitial_didAdClickedWithAdapter:self];
}

- (void)onAdClose:(TXAdModel *)model{
    [self.bridge interstitial_didAdClosedWithAdapter:self];
}

- (void)onAdRenderFail:(TXAdModel *)model withError:(NSError *)error {
    [self.bridge interstitial_failedToShowAdWithAdapter:self error:error];
}

- (void)dealloc {
    
}

@end
