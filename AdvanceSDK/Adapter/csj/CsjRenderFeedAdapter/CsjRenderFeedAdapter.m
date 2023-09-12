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

@interface CsjRenderFeedAdapter () <BUNativeAdsManagerDelegate>

@property (nonatomic, strong) BUNativeAdsManager *csj_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
 
@end

@implementation CsjRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
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

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载穿山甲 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_csj_ad loadAdDataWithCount:1];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"穿山甲加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"穿山甲 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"穿山甲 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (self.csj_ad) {
        self.csj_ad.delegate = nil;
        self.csj_ad = nil;
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    [self deallocAdapter];
}

#pragma mark - BUNativeAdsManagerDelegate
- (void)nativeAdsManagerSuccessToLoad:(BUNativeAdsManager *)adsManager nativeAds:(NSArray<BUNativeAd *> *_Nullable)nativeAdDataArray {
    
    BUNativeAd *nativeAd = nativeAdDataArray.firstObject;
    NSDictionary *ext = nativeAd.data.mediaExt;
    _supplier.supplierPrice = [ext[@"price"] integerValue];
    [_adspot reportWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
    [_adspot reportWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    
    
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithNativeAd:nativeAd];
    CSJRenderFeedAdView *csjFeedAdView = [[CSJRenderFeedAdView alloc] initWithNativeAd:nativeAd delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:csjFeedAdView feedAdElement:element];
    
    if (_supplier.isParallel == YES) {
        _supplier.state = AdvanceSdkSupplierStateSuccess;
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
    
}

- (void)nativeAdsManager:(BUNativeAdsManager *)adsManager didFailWithError:(NSError *)error {
    [self.adspot reportWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
    _supplier.state = AdvanceSdkSupplierStateFailed;
    if (_supplier.isParallel == YES) { // 并行不释放 只上报
        return;
    }

    _csj_ad = nil;
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
    element.videoUrl = data.videoUrl;
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
