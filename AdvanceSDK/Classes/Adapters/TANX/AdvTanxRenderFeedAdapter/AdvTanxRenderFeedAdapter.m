//
//  AdvTanxRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "AdvTanxRenderFeedAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRenderFeedCommonAdapter.h"
#import "AdvRenderFeedAdWrapper.h"
#import "AdvTanxRenderFeedAdView.h"
#import "AdvAdConfigHeader.h"
#import "AdvError.h"

@interface AdvTanxRenderFeedAdapter () <AdvanceRenderFeedCommonAdapter>

@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, copy) NSString *adapterId;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, strong) TXAdFeedBinder *binder;

@end

@implementation AdvTanxRenderFeedAdapter

@synthesize delegate = _delegate;

- (void)adapter_setupWithAdapterId:(NSString *)adapterId placementId:(NSString *)placementId config:(NSDictionary *)config {
    _adapterId = adapterId;
    
    TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
    slotModel.pid = placementId;
    slotModel.showAdFeedBackView = NO;
    _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
}

- (void)adapter_loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeCustom adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            [strongSelf.delegate renderAdapter_failedToLoadAdWithAdapterId:self.adapterId error:error];
            return;
        }
        
        TXAdFeedBinder *binder = [strongSelf.tanx_ad customRenderingBinderWithModels:viewModelArray].firstObject;
        strongSelf.binder = binder;
        NSInteger ecpm = binder.adModel.bid.bidPrice.integerValue;
        AdvRenderFeedAdElement *element = [strongSelf generateFeedAdElementWithAdModel:binder.adModel];
        AdvTanxRenderFeedAdView<TXAdFeedManagerDelegate> *tanxFeedAdView = [[AdvTanxRenderFeedAdView alloc] initWithBinder:binder delegate:strongSelf.delegate adapterId:self.adapterId];
        strongSelf.tanx_ad.delegate = tanxFeedAdView;
        strongSelf.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:tanxFeedAdView feedAdElement:element];
        
        [strongSelf.delegate adapter_cacheAdapterIfNeeded:strongSelf adapterId:strongSelf.adapterId price:ecpm];
        [strongSelf.delegate renderAdapter_didLoadAdWithAdapterId:self.adapterId price:ecpm];
    }];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
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
