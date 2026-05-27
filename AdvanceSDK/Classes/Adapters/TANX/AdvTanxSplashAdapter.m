//
//  AdvTanxSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxSplashAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvTanxSplashAdapter () <TXAdSplashManagerDelegate, AdvanceCommonSplashAdapter>

@property (nonatomic, weak) id<AdvanceCommonSplashAdapterBridge> bridge;
@property(nonatomic, strong)TXAdSplashManager *tanx_ad;
@property (nonatomic, strong) TXAdModel *adModel;
@property(nonatomic, strong) UIView *templateView;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvTanxSplashAdapter

- (void)adapter_setSplashBridge:(id<AdvanceCommonSplashAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    
    TXAdSplashSlotModel *slotModel = [[TXAdSplashSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.waitSyncTimeout = timeout * 1.0 / 1000.0;
    _tanx_ad = [[TXAdSplashManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getSplashAdsWithAdsDataBlock:^(NSArray<TXAdModel *> *splashModels, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.bridge splash_failedToLoadAdWithAdapter:strongSelf error:error];
        } else { // 获取广告成功
            strongSelf.adModel = splashModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.bridge splash_didLoadAdWithAdapter:strongSelf price:ecpm];
        }
    }];
}

- (void)adapter_showAdInWindow:(UIWindow *)window {
    CGRect adFrame = [UIScreen mainScreen].bounds;
    // 设置logo
    if (_bottomLogoView) {
        adFrame.size.height -= _bottomLogoView.bounds.size.height;
        _bottomLogoView.frame = CGRectMake(0, UIScreen.mainScreen.bounds.size.height - _bottomLogoView.bounds.size.height, UIScreen.mainScreen.bounds.size.width, _bottomLogoView.bounds.size.height);
        [window addSubview:_bottomLogoView];
    }
    TXAdSplashTemplateConfig *config = [[TXAdSplashTemplateConfig alloc] init];
    self.templateView = [self.tanx_ad renderSplashTemplateWithAdModel:self.adModel config:config];
    self.templateView.frame = adFrame;
    [window addSubview:self.templateView];
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

#pragma mark: -TXAdSplashManagerDelegate
/// 展示
- (void)onSplashShow {
    [self.bridge splash_didAdExposuredWithAdapter:self];
}

/// 关闭
- (void)onSplashClose {
    [_bottomLogoView removeFromSuperview];
    [_templateView removeFromSuperview];
    _templateView = nil;
    [self.bridge splash_didAdClosedWithAdapter:self];
}

- (void)onAdClick:(TXAdModel *)model {
    [self.bridge splash_didAdClickedWithAdapter:self];
}

- (void)dealloc {
    
}

@end
