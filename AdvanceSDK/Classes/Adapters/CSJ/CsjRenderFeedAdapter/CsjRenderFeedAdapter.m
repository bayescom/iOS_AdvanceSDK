//
//  CsjRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "CsjRenderFeedAdapter.h"
#if __has_include(<BUAdSDK/BUAdSDK.h>)
#import <BUAdSDK/BUAdSDK.h>
#else
#import "BUAdSDK.h"
#endif
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "CSJRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface CsjRenderFeedAdapter () <BUNativeAdsManagerDelegate, AdvanceAdapter>

@property (nonatomic, strong) BUNativeAdsManager *csj_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
 
@end

@implementation CsjRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        
        BUAdSlot *slot = [[BUAdSlot alloc] init];
        slot.ID = _supplier.adspotid;
        slot.AdType = BUAdSlotAdTypeFeed;
        slot.position = BUAdSlotPositionTop;
        slot.imgSize = [BUSize sizeBy:BUProposalSize_Feed690_388];
        _csj_ad = [[BUNativeAdsManager alloc] initWithSlot:slot];
        _csj_ad.delegate = self;
        
    }
    return self;
}

- (void)loadAd {
    [_csj_ad loadAdDataWithCount:1];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    
    if (!nativeAdDataArray.count) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:[NSError errorWithDomain:@"BUNative.com" code:1 userInfo:@{@"msg":@"无广告返回"}]];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    NSDictionary *ext = nativeAd.data.mediaExt;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    CSJRenderFeedAdView *csjFeedAdView = [[CSJRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:csjFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:[ext[@"price"] integerValue] supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
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

@end
