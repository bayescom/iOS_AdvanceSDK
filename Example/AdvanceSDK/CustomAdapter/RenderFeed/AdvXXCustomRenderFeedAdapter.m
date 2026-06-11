//
//  AdvXXCustomRenderFeedAdapter.m
//  AdvanceSDK_Example
//
//  Created by guangyao on 2026/6/8.
//  Copyright © 2026. All rights reserved.
//

#import "AdvXXCustomRenderFeedAdapter.h"
#import <BUAdSDK/BUAdSDK.h>
#import <AdvanceSDK/AdvanceCommonAdapter.h>
#import <AdvanceSDK/AdvAdConfigHeader.h>
#import <AdvanceSDK/AdvRenderFeedAdWrapper.h>
#import "AdvXXRenderFeedAdView.h"

@interface AdvXXCustomRenderFeedAdapter () <BUNativeAdsManagerDelegate, AdvanceCommonRenderFeedAdapter>

@property (nonatomic, weak) id<AdvanceCommonRenderFeedAdapterBridge> bridge;
@property (nonatomic, strong) BUNativeAdsManager *nativeAdManager;
@property (nonatomic, strong) BUNativeAd *nativeAd;
@property (nonatomic, strong) AdvRenderFeedAdWrapper *feedAdWrapper;
@property (nonatomic, weak) UIViewController *rootViewController;
 
@end

@implementation AdvXXCustomRenderFeedAdapter

- (void)adapter_setRenderFeedBridge:(id<AdvanceCommonRenderFeedAdapterBridge>)bridge {
    _bridge = bridge;
}

- (void)adapter_loadAdWithPlacementId:(NSString *)placementId config:(NSDictionary *)config {
    _rootViewController = config[kAdvanceAdPresentControllerKey];
    
    BUAdSlot *slot = [[BUAdSlot alloc] init];
    slot.ID = placementId;
    slot.AdType = BUAdSlotAdTypeFeed;
    slot.position = BUAdSlotPositionTop;
    slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
    _nativeAdManager = [[BUNativeAdsManager alloc] initWithSlot:slot];
    _nativeAdManager.delegate = self;
    [_nativeAdManager loadAdDataWithCount:1];
}

- (id)adapter_renderFeedAdWrapper {
    return self.feedAdWrapper;
}

- (void)adapter_sendNotificationWithBidResult:(AdvBidWinLossResult *)result {
    if (result.bidResultType == AdvBidWinLossResultTypeWin) {
        [_nativeAd win:@(result.secondPrice)];
    } else {
        [_nativeAd loss:@(result.winPrice) lossReason:nil winBidder:nil];
    }
}


#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    if (!nativeAdDataArray.count) {
        NSError *error = [NSError errorWithDomain:@"BUAdErrorDomain" code:1 userInfo:@{NSLocalizedDescriptionKey: @"无广告返回"}];
        [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
        return;
    }
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    self.nativeAd = nativeAd;
    NSDictionary *ext = nativeAd.data.mediaExt;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    AdvXXRenderFeedAdView *csjFeedAdView = [[AdvXXRenderFeedAdView alloc] initWithNativeAd:nativeAd bridge:self.bridge adapter:self manager:nil viewController:self.rootViewController];
    self.feedAdWrapper = [[AdvRenderFeedAdWrapper alloc] initWithFeedAdView:csjFeedAdView feedAdElement:element];
    
    [self.bridge renderFeed_didLoadAdWithAdapter:self price:[ext[@"price"] integerValue]];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.bridge renderFeed_failedToLoadAdWithAdapter:self error:error];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithNativeAd:(BUNativeAd *)nativeAd {
    BUMaterialMeta *data = nativeAd.data;
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = data.AdTitle;
    element.desc = data.AdDescription;
    element.iconUrl = data.icon.imageURL;
    NSMutableArray *urlList = [NSMutableArray array];
    for (BUImage * image in data.imageAry) {
        [urlList addObject:image.imageURL];
    }
    element.imageUrlList = [urlList copy];
    element.mediaWidth = data.imageAry.firstObject.width;
    element.mediaHeight = data.imageAry.firstObject.height;
    element.buttonText = data.buttonText;
    element.isVideoAd = [self isVideoAd:nativeAd];
    if (element.isVideoAd) {
        element.mediaWidth = data.videoResolutionWidth;
        element.mediaHeight = data.videoResolutionHeight;
    }
    element.videoDuration = data.videoDuration;
    element.appRating = data.score;
    element.isAdValid = YES;
    
    return element;
}

- (BOOL)isVideoAd:(BUNativeAd *)nativeAd {
    switch (nativeAd.data.imageMode) {
        case BUFeedVideoAdModeImage:
        case BUFeedVideoAdModePortrait:
        case BUFeedADModeSquareVideo:
        //Live Stream Ad. v5200 add
        case 166:
            return YES;
            
        default:
            return NO;
    }
}

- (void)dealloc {
    
}

@end
