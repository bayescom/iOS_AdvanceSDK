//
//  TanxRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/4/17.
//

#import "TanxRenderFeedAdapter.h"
#import <TanxSDK/TanxSDK.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "TanxRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface TanxRenderFeedAdapter () <AdvanceAdapter>

@property (nonatomic, strong) TXAdFeedManager *tanx_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
@property (nonatomic, strong) TXAdFeedBinder *binder;

@end

@implementation TanxRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        TXAdFeedSlotModel *slotModel = [[TXAdFeedSlotModel alloc] init];
        slotModel.pid = _supplier.adspotid;
        slotModel.showAdFeedBackView = NO;
        _tanx_ad = [[TXAdFeedManager alloc] initWithSlotModel:slotModel];
    }
    return self;
}

- (void)loadAd {
    __weak typeof(self) weakSelf = self;
    [self.tanx_ad getFeedAdsWithAdCount:1 renderMode:TXAdRenderModeCustom adsBlock:^(NSArray<TXAdModel *> * _Nullable viewModelArray, NSError * _Nullable error) {
        if (error) {
            [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:weakSelf.supplier error:error];
            [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdFailed];
            return;
        }
        
        TXAdFeedBinder *binder = [weakSelf.tanx_ad customRenderingBinderWithModels:viewModelArray].firstObject;
        weakSelf.binder = binder;
        NSInteger ecpm = binder.adModel.bid.bidPrice.integerValue;
        if (ecpm > 0) {
            [weakSelf.tanx_ad uploadBidding:binder.adModel result:YES];
        }
        AdvRenderFeedAdElement *element = [weakSelf generateFeedAdElementWithAdModel:binder.adModel];
        TanxRenderFeedAdView<TXAdFeedManagerDelegate> *tanxFeedAdView = [[TanxRenderFeedAdView alloc] initWithBinder:binder delegate:weakSelf.delegate adSpot:weakSelf.adspot supplier:weakSelf.supplier];
        weakSelf.tanx_ad.delegate = tanxFeedAdView;
        weakSelf.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:tanxFeedAdView feedAdElement:element];
        
        [weakSelf.adspot.manager setECPMIfNeeded:ecpm supplier:weakSelf.supplier];
        [weakSelf.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:weakSelf.supplier error:nil];
        [weakSelf.adspot.manager checkTargetWithResultfulSupplier:weakSelf.supplier loadAdState:AdvanceSupplierLoadAdSuccess];
    }];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
    [self.binder destoryBinder];
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
    return element;
}

@end
