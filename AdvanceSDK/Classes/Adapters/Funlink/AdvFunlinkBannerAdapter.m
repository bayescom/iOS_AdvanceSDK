//
//  AdvFunlinkBannerAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkBannerAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvFunlinkBannerAdapter () <FLinkBannerDelegate, AdvanceCommonBannerAdapter>

@property (nonatomic, weak) id<AdvanceCommonBannerAdapterBridge> bridge;
@property (nonatomic, strong) FLinkBannerManager *flink_ad;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvFunlinkBannerAdapter

- (void)adapter_setBannerBridge:(id<AdvanceCommonBannerAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _flink_ad = [[FLinkBannerManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    _flink_ad.showAdController = config[kAdvanceAdPresentControllerKey];
    _bannerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _flink_ad.size.width, _flink_ad.size.height)];
    [_flink_ad loadAdData];
}

- (BOOL)adapter_isAdValid {
    return _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
}

- (UIView *)adapter_bannerView {
    [_flink_ad showBannerAdWithView:self.bannerView];
    return self.bannerView;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_flink_ad sendWinNotificationWithPrice:result.secondPrice];
    } else {
        [_flink_ad sendLossNotificationWithPrice:result.winPrice];
    }
}

#pragma mark: - FLinkBannerDelegate
- (void)bannerAdDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.bridge banner_didLoadAdWithAdapter:self price:ecpm];
}

- (void)bannerAdDidFailed:(NSError *)error {
    [self.bridge banner_failedToLoadAdWithAdapter:self error:error];
}

- (void)bannerAdDidVisible {
    [self.bridge banner_didAdExposuredWithAdapter:self];
}

- (void)bannerAdDidClick {
    [self.bridge banner_didAdClickedWithAdapter:self];
}

- (void)bannerAdDidClose {
    [_bannerView removeFromSuperview];
    _flink_ad = nil;
    [self.bridge banner_didAdClosedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
