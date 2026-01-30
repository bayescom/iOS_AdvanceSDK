//
//  AdvTanxSplashAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxSplashAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceSplashCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvTanxSplashAdapter () <TXAdSplashManagerDelegate, AdvanceSplashCommonAdapter>
@property(nonatomic, strong)TXAdSplashManager *tanx_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) TXAdModel *adModel;
@property(nonatomic, strong) UIView *templateView;
@property (nonatomic, strong) UIView *bottomLogoView;

@end

@implementation AdvTanxSplashAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    _bottomLogoView = config[kAdvanceSplashBottomViewKey];
    NSInteger timeout = [config[kAdvanceAdLoadTimeoutKey] integerValue];
    
    TXAdSplashSlotModel *slotModel = [[TXAdSplashSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.waitSyncTimeout = timeout * 1.0 / 1000.0;
    _tanx_ad = [[TXAdSplashManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
}

- (void)adapter_loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getSplashAdsWithAdsDataBlock:^(NSArray<TXAdModel *> *splashModels, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.delegate splashAdapter_failedToLoadAdWithAdapterId:strongSelf.adapterId error:error];
        } else { // 获取广告成功
            strongSelf.adModel = splashModels.firstObject;
            NSInteger ecpm = strongSelf.adModel.bid.bidPrice.integerValue;
            [strongSelf.delegate adapter_cacheAdapterIfNeeded:self adapterId:self.adapterId price:ecpm];
            [strongSelf.delegate splashAdapter_didLoadAdWithAdapterId:strongSelf.adapterId price:ecpm];
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

#pragma mark: -TXAdSplashManagerDelegate
/// 展示
- (void)onSplashShow {
    [self.delegate splashAdapter_didAdExposuredWithAdapterId:self.adapterId];
}

/// 关闭
- (void)onSplashClose {
    [_bottomLogoView removeFromSuperview];
    [_templateView removeFromSuperview];
    _templateView = nil;
    [self.delegate splashAdapter_didAdClosedWithAdapterId:self.adapterId];
}

- (void)onAdClick:(TXAdModel *)model {
    [self.delegate splashAdapter_didAdClickedWithAdapterId:self.adapterId];
}

- (void)dealloc {
    
}

@end
