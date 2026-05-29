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
#import "AdvTanxRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"

@interface AdvTanxRenderFeedAdapter () <AdvanceCommonRenderFeedAdapter>

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
    
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeCustom adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf.bridge renderFeed_failedToLoadAdWithAdapter:strongSelf error:error];
            return;
        }
        
        TXAdFeedBinder *binder = [strongSelf.tanx_ad customRenderingBinderWithModels:viewModelArray].firstObject;
        strongSelf.binder = binder;
        NSInteger ecpm = binder.adModel.bid.bidPrice.integerValue;
        AdvRenderFeedAdElement *element = [strongSelf generateFeedAdElementWithAdModel:binder.adModel];
        AdvTanxRenderFeedAdView *tanxFeedAdView = [[AdvTanxRenderFeedAdView alloc] initWithNativeAd:binder bridge:strongSelf.bridge adapter:strongSelf manager:nil viewController:nil];
        strongSelf.tanx_ad.delegate = tanxFeedAdView;
        strongSelf.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:tanxFeedAdView feedAdElement:element];
        
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


- (AdvRenderFeedAdElement *)generateFeedAdElementWithAdModel:(TXAdModel *)adModel {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    NSDictionary *dict = adModel.adMaterialDict;
    element.title = dict[@"title"];
    element.desc = dict[@"description"];
    element.iconUrl = dict[@"smImageUrl"];
    element.imageUrlList = @[dict[@"assetUrl"] ?: @""];
    element.mediaWidth = [dict[@"width"] integerValue];
    element.mediaHeight = [dict[@"height"] integerValue];
    element.isVideoAd = adModel.adType == TanXAdTypeFeedVideo;
    element.isAdValid = YES;
    return element;
}

- (void)dealloc {
    [self.binder destoryBinder];
}

@end
