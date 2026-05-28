//
//  AdvCSJNativeExpressAdapter.m
//  AdvanceSDK
//
//  Created by CherryKing on 2020/4/9.
//  Copyright © 2020 bayescom. All rights reserved.
//

#import "AdvCSJNativeExpressAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import "AdvanceCommonAdapter.h"
#import "AdvAdConfigHeader.h"

@interface AdvCSJNativeExpressAdapter () <BUNativeExpressAdViewDelegate, BUCustomEventProtocol, AdvanceCommonNativeExpressAdapter>

@property (nonatomic, weak) id<AdvanceCommonNativeExpressAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeExpressAdManager *csj_ad;
@property (nonatomic, strong) BUNativeExpressAdView *expressAdView;

@end

@implementation AdvCSJNativeExpressAdapter

- (void)adapter_setNativeExpressBridge:(id<AdvanceCommonNativeExpressAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = placementId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionFeed;
    slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed228_150];
    _csj_ad = [[BUNativeExpressAdManager alloc] initWithSlot:slot adSize:[config[kAdvanceAdSizeKey] CGSizeValue]];
    _csj_ad.delegate = self;
    [_csj_ad loadAdDataWithCount:1];
}

- (void)adapter_renderAd:(UIViewController *)viewController {
    [self.expressAdView render];
    self.expressAdView.rootViewController = viewController;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [self.expressAdView win:@(result.secondPrice)];
    } else {
        [self.expressAdView loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}

#pragma mark: - BUNativeExpressAdViewDelegate
- (void)nativeExpressAdSuccessToLoad:(id)nativeExpressAd views:(nonnull NSArray<__kindof BUNativeExpressAdView *> *)views {
    if (!views.count) {
        NSError *error = [NSError errorWithDomain:@"BUAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    self.expressAdView = views.firstObject;
    NSDictionary *ext = views.firstObject.mediaExt;
    [self.bridge nativeExpress_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeExpressAdFailToLoad:(BUNativeExpressAdManager *)nativeExpressAd error:(NSError *)error {
    [self.bridge nativeExpress_failedToLoadAdWithAdapter:self error:error];
}

- (void)nativeExpressAdViewRenderSuccess:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdRenderSuccessWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdViewRenderFail:(BUNativeExpressAdView *)nativeExpressAdView error:(NSError *)error {
    [self.bridge nativeExpress_didAdRenderFailWithAdapter:self expressView:nativeExpressAdView error:error];
}

- (void)nativeExpressAdViewWillShow:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdExposuredWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdViewDidClick:(BUNativeExpressAdView *)nativeExpressAdView {
    [self.bridge nativeExpress_didAdClickedWithAdapter:self expressView:nativeExpressAdView];
}

- (void)nativeExpressAdView:(BUNativeExpressAdView *)nativeExpressAdView dislikeWithReason:(NSArray<BUDislikeWords *> *)filterWords {
    [self.bridge nativeExpress_didAdClosedWithAdapter:self expressView:nativeExpressAdView];
}

- (void)dealloc {
    
}

@end
