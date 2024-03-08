//
//  TanxRewardVideoAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "TanxRewardVideoAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRewardVideo.h"
#import "AdvLog.h"
#import "AdvanceAdapter.h"

@interface TanxRewardVideoAdapter () <TXAdRewardAdsDelegate, AdvanceAdapter>
@property (nonatomic, strong) TXAdRewardManager *tanx_ad;
@property (nonatomic, weak) AdvanceRewardVideo *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) TXAdModel *adModel;

@end

@implementation TanxRewardVideoAdapter

@synthesize isWinnerAdapter = _isWinnerAdapter;
@synthesize isVideoCached = _isVideoCached;

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        TXAdRewardVideoSlotModel *slotModel = [[TXAdRewardVideoSlotModel alloc] init];
        slotModel.defaultAudioState = (_adspot.muted ? TXAdRewardVideoAdDefaultAudioStateMuted : TXAdRewardVideoAdDefaultAudioStateVocal);
        slotModel.pid = _supplier.adspotid;
        _tanx_ad = [[TXAdRewardManager alloc] initWithSlotModel:slotModel];
        _tanx_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getRewardAdsWithAdsDataBlock:^(NSArray<TXAdModel *> * _Nullable rewardAdModels, NSError * _Nullable error) {
        if (error) { // 获取广告失败
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:weakSelf.supplier error:error];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdFailed];
            
        } else { // 获取广告成功
            self.adModel = rewardAdModels.firstObject;
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
    [self.tanx_ad showAdFromRootViewController:self.adspot.viewController withModel:self.adModel];
}

- (void)winnerAdapterToShowAd {
    _isWinnerAdapter = YES;
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRewardedVideoADWithSpotId:)]) {
        [self.delegate didFinishLoadingRewardedVideoADWithSpotId:self.adspot.adspotid];
    }
    if (_isVideoCached && [self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (BOOL)isAdValid {
    return YES;
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark: -TXAdRewardAdsDelegate

- (void)onAdShow:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoImped supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidStartPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidStartPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdDidShowFailError:(NSError *)error withModel:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
}

- (void)onAdDidDownLoadSuccessWithModel:(TXAdModel *)model {
    _isVideoCached = YES;
    /// 竞胜方才进行缓存成功回调
    if (_isWinnerAdapter && [self.delegate respondsToSelector:@selector(rewardedVideoDidDownLoadForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidDownLoadForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdClose:(TXAdModel *)model {
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidCloseForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidCloseForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdClick:(TXAdModel *)model {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoClicked supplier:_supplier error:nil];
    if ([self.delegate respondsToSelector:@selector(rewardedVideoDidClickForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidClickForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

- (void)onAdDidReceiveRewardInfo:(TXAdRewardVideoRewardInfo *)rewardInfo withModel:(TXAdModel *)model {
    if (rewardInfo.isValid && [self.delegate respondsToSelector:@selector(rewardedVideoDidRewardSuccessForSpotId:extra:rewarded:)]) {
        [self.delegate rewardedVideoDidRewardSuccessForSpotId:self.adspot.adspotid extra:self.adspot.ext rewarded:YES];
    }
}

- (void)onAdDidFinishPlayingError:(NSError *)error withModel:(TXAdModel *)model {
    if (!error && [self.delegate respondsToSelector:@selector(rewardedVideoDidEndPlayingForSpotId:extra:)]) {
        [self.delegate rewardedVideoDidEndPlayingForSpotId:self.adspot.adspotid extra:self.adspot.ext];
    }
}

@end
