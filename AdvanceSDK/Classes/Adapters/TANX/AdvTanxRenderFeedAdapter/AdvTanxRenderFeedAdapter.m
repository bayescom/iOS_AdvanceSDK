//
//  AdvTanxRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "AdvTanxRenderFeedAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvTanxRenderFeedAdViewCreator.h"
#import "AdvTanxRenderFeedAdDataSource.h"
#import "AdvAdConfigHeader.h"

@interface AdvTanxRenderFeedAdapter () <TXAdFeedManagerDelegate, TXAdFeedPlayerViewDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, strong) TXAdFeedBinder *binder;

@end

@implementation AdvTanxRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.showAdFeedBackView = NO;
    _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
    _tanx_ad.delegate = self;
    
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeCustom adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf.bridge renderFeed_failedToLoadAdWithAdapter:strongSelf error:error];
            return;
        }
        
        TXAdFeedBinder *binder = [strongSelf.tanx_ad customRenderingBinderWithModels:viewModelArray].firstObject;
        strongSelf.binder = binder;
        id<AdvRenderFeedAdDataSource> dataSource = [[AdvTanxRenderFeedAdDataSource alloc] initWithAdModel:binder.adModel];
        TXAdFeedPlayerView *tanxVideoView = nil;
        if (dataSource.isVideoAd) {
            TXAdFeedTemplateConfig *config =  [[TXAdFeedTemplateConfig alloc] init];
            tanxVideoView = [binder getVideoAdViewWithFrame:CGRectZero playConfig:config];
            tanxVideoView.delegate = strongSelf;
        }
        // 必须设置frame，否则bind失效影响曝光
        TXAdFeedView *adView = [[TXAdFeedView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        strongSelf.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] init];
        strongSelf.feedAdWrapper.dataSource = dataSource;
        strongSelf.feedAdWrapper.view = adView;
        strongSelf.feedAdWrapper.viewCreator = [[AdvTanxRenderFeedAdViewCreator alloc] initWithBinder:binder adView:adView videoView:tanxVideoView];
        
        NSInteger ecpm = binder.adModel.bid.bidPrice.integerValue;
        [strongSelf.bridge renderFeed_didLoadAdWithAdapter:strongSelf price:ecpm];
    }];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_tanx_ad uploadBidding:_binder.adModel result:YES];
    } else {
        [_tanx_ad uploadBidding:_binder.adModel result:NO];
    }
}

#pragma mark: - TXAdFeedManagerDelegate
- (void)onAdExposing:(TXAdModel *)model {
    [self.bridge renderFeed_didAdExposuredWithAdapter:self];
}

- (void)onAdClick:(TXAdModel *)model clickView:(UIView *)clickView {
    [self.bridge renderFeed_didAdClickedWithAdapter:self];
}

- (void)onAdClose:(TXAdModel *)model {
    
}

#pragma mark - TXAdFeedPlayerViewDelegate
- (void)onVideoComplete {
    [self.bridge renderFeed_didAdPlayFinishWithAdapter:self];
}

- (void)dealloc {
    [self.binder destoryBinder];
}

@end
