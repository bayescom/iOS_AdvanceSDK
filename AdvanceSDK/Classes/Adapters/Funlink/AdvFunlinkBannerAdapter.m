//
//  AdvFunlinkBannerAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2026/4/14.
//

#import "AdvFunlinkBannerAdapter.h"
#import <FLinkAdSaas/FLinkAdSaas.h>
#import "AdvanceBannerCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvFunlinkBannerAdapter () <FLinkBannerDelegate, AdvanceBannerCommonAdapter>
@property (nonatomic, strong) FLinkBannerManager *flink_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) UIView *bannerView;

@end

@implementation AdvFunlinkBannerAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _flink_ad = [[FLinkBannerManager alloc] init];
    _flink_ad.delegate = self;
    _flink_ad.mediaId = placementId;
    _flink_ad.size = [config[kAdvanceAdSizeKey] CGSizeValue];
    _flink_ad.showAdController = config[kAdvanceAdPresentControllerKey];
    _bannerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _flink_ad.size.width, _flink_ad.size.height)];
}

- (void)adapter_loadAd {
    [_flink_ad loadAdData];
}

- (BOOL)adapter_isAdValid {
    BOOL valid = _flink_ad.getCurrentBaseEcpmInfo.isAdValid;
    if (!valid) {
        [self.delegate bannerAdapter_failedToShowAdWithAdapterId:self.adapterId error:[AdvError errorWithCode:AdvErrorCode_InvalidExpired].toNSError];
    }
    return valid;
}

- (id)adapter_bannerView {
    [_flink_ad showBannerAdWithView:self.bannerView];
    return self.bannerView;
}

- (void)adapter_sendWinNotificationWithSecondPrice:(NSInteger)secondPrice winPrice:(NSInteger)winPrice {
    [_flink_ad sendWinNotificationWithPrice:secondPrice];
}

- (void)adapter_sendLossNotificationWithFirstPrice:(NSInteger)firstPrice {
    [_flink_ad sendLossNotificationWithPrice:firstPrice];
}

#pragma mark: - FLinkBannerDelegate
- (void)bannerAdDidLoad {
    NSInteger ecpm = self.flink_ad.getCurrentBaseEcpmInfo.ecpm;
    [self.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
    [self.delegate bannerAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
}

- (void)bannerAdDidFailed:(NSError *)error {
    [self.delegate bannerAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
}

- (void)bannerAdDidVisible {
    [self.delegate bannerAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

- (void)bannerAdDidClick {
    [self.delegate bannerAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)bannerAdDidClose {
    [_bannerView removeFromSuperview];
    _flink_ad = nil;
    [self.delegate bannerAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
