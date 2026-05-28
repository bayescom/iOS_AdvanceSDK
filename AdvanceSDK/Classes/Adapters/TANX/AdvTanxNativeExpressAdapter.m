//
//  AdvTanxNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/7.
//

#import "AdvTanxNativeExpressAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvTanxNativeExpressAdapter () <TXAdFeedManagerDelegate, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, strong) NSArray *adModels;
@property (nonatomic, strong) UIView *expressAdView;
@property (nonatomic, assign) CGSize adSize;

@end

@implementation AdvTanxNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _adSize = [config[kAdvanceAdSizeKey] CGSizeValue];
    TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.showAdFeedBackView = NO;
    _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeTemplate adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) { // 获取广告失败
            [strongSelf.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        } else { // 获取广告成功
            strongSelf.adModels = viewModelArray;
            NSInteger ecpm = viewModelArray.firstObject.bid.bidPrice.integerValue;
            [strongSelf.bridge nativeExpress_didLoadAdWithAdapter:strongSelf price:ecpm];
        }
    }];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    TXAdFeedTemplateConfig *config = [[TXAdFeedTemplateConfig alloc] init];
    config.templateWidth = self.adSize.width - 2 * 15.0;
    NSError *error;
    NSArray<TXAdFeedModule *> *feedModules = [self.tanx_ad renderFeedTemplateWithModel:self.adModels config:config error:&error];
    
    if (!error) { /// render success
        self.expressAdView = feedModules.firstObject.view;
        [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:self.expressAdView];
    } else { /// render fail
        [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:self.expressAdView error:error];
    }
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_tanx_ad uploadBidding:_adModels.firstObject result:YES];
    } else {
        [_tanx_ad uploadBidding:_adModels.firstObject result:NO];
    }
}


#pragma mark: - TXAdFeedManagerDelegate
/// ❌❌ 当feedModules获取为空时，还是会进入渲染成功回调
- (void)onAdRenderSuccess:(TXAdModel *)model {
    
}

- (void)onAdExposing:(TXAdModel *)model {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:self.expressAdView];
}

/// 广告点击
- (void)onAdClick:(TXAdModel *)model {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:self.expressAdView];
}

/// 广告滑动跳转
- (void)onAdSliding:(TXAdModel *)model {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:self.expressAdView];
}

- (void)onAdClose:(TXAdModel *)model {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:self.expressAdView];
}

- (void)dealloc {
    
}

@end
