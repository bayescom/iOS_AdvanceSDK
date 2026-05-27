//
//  AdvTanxRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxRewardVideoAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvRewardVideoModel.h"

@interface AdvTanxRewardVideoAdapter () <TXAdRewardAdsDelegate, AdvanceCommonRewardVideoAdapter>

@property (nonatomic, weak) id<AdvanceCommonRewardVideoAdapterBridge> bridge;
@property (nonatomic, strong) TXAdRewardManager *tanx_ad;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation AdvTanxRewardVideoAdapter

- (void)adapter_setRewardVideoBridge:(id<AdvanceCommonRewardVideoAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    TXAdRewardVideoSlotModel *slotModel = [[TXAdRewardVideoSlotModel alloc] init];
    slotModel.defaultAudioState = ([config[kAdvanceAdVideoMutedKey] boolValue] ? TXAdRewardVideoAdDefaultAudioStateMuted : TXAdRewardVideoAdDefaultAudioStateVocal);
    slotModel.pid = placementId;
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        slotModel.mediaUid = rewardVideoModel.userId;
    }
    _tanx_ad = [[TXAdRewardManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getRewardAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable rewardAdModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.bridge rewardVideo_failedToLoadAdWithAdapter:strongSelf error:error];
        } else { // 获取广告成功
            strongSelf.adModel = rewardAdModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.bridge rewardVideo_didLoadAdWithAdapter:strongSelf price:ecpm];
        }
    }];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [self.tanx_ad showAdFromRootViewController:rootViewController withModel:self.adModel openType:TXAdViewOpenTypePresent];
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

#pragma mark: -TXAdRewardAdsDelegate
- (void)onAdShow:(TXAdModel *)model {
    [self.bridge rewardVideo_didAdExposuredWithAdapter:self];
}

- (void)onAdClick:(TXAdModel *)model {
    [self.bridge rewardVideo_didAdClickedWithAdapter:self];
}

- (void)onAdClose:(TXAdModel *)model {
    [self.bridge rewardVideo_didAdClosedWithAdapter:self];
}

- (void)onAdDidReceiveRewardInfo:(TXAdRewardVideoRewardInfo *)rewardInfo withModel:(TXAdModel *)model {
    [self.bridge rewardVideo_didAdVerifyRewardWithAdapter:self];
}

- (void)onAdDidPlayFinish:(TXAdModel *)model {
    [self.bridge rewardVideo_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    
}

@end
