//
//  AdvTanxRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxRewardVideoAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRewardVideoCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"
#import "AdvRewardVideoModel.h"

@interface AdvTanxRewardVideoAdapter () <TXAdRewardAdsDelegate, AdvanceRewardVideoCommonAdapter>
@property (nonatomic, strong) TXAdRewardManager *tanx_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation AdvTanxRewardVideoAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
    TXAdRewardVideoSlotModel *slotModel = [[TXAdRewardVideoSlotModel alloc] init];
    slotModel.defaultAudioState = ([config[kAdvanceAdVideoMutedKey] boolValue] ? TXAdRewardVideoAdDefaultAudioStateMuted : TXAdRewardVideoAdDefaultAudioStateVocal);
    slotModel.pid = placementId;
    AdvRewardVideoModel *rewardVideoModel = config[kAdvanceRewardVideoModelKey];
    if (rewardVideoModel) {
        slotModel.mediaUid = rewardVideoModel.userId;
    }
    _tanx_ad = [[TXAdRewardManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
}

- (void)adapter_loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getRewardAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable rewardAdModels, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.delegate rewardAdapter_failedToLoadAdWithAdapterId:strongSelf.adapterId error:error];
        } else { // 获取广告成功
            strongSelf.adModel = rewardAdModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.delegate adapter_cacheAdapterIfNeeded:strongSelf adapterId:strongSelf.adapterId price:ecpm];
            [strongSelf.delegate rewardAdapter_didLoadAdWithAdapterId:strongSelf.adapterId price:ecpm];
        }
    }];
}

- (void)adapter_showAdFromRootViewController:(UIViewController *)rootViewController {
    [self.tanx_ad showAdFromRootViewController:rootViewController withModel:self.adModel openType:TXAdViewOpenTypePresent];
}

- (BOOL)adapter_isAdValid {
    return YES;
}

#pragma mark: -TXAdRewardAdsDelegate
- (void)onAdShow:(TXAdModel *)model {
    [self.delegate rewardAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)onAdClick:(TXAdModel *)model {
    [self.delegate rewardAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)onAdClose:(TXAdModel *)model {
    [self.delegate rewardAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)onAdDidReceiveRewardInfo:(TXAdRewardVideoRewardInfo *)rewardInfo withModel:(TXAdModel *)model {
    [self.delegate rewardAdapter_didAdVerifyRewardWithAdapterId:self.adapterId];
}

- (void)onAdDidPlayFinish:(TXAdModel *)model {
    [self.delegate rewardAdapter_didAdPlayFinishWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
