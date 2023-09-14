//
//  GdtRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "GdtRenderFeedAdapter.h"
#if __has_include(<GDTUnifiedNativeAd.h>)
#import <GDTUnifiedNativeAd.h>
#else
#import "GDTUnifiedNativeAd.h"
#endif

#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "GdtRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"

@interface GdtRenderFeedAdapter () <GDTUnifiedNativeAdDelegate>

@property (nonatomic, strong) GDTUnifiedNativeAd *gdt_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
 
@end

@implementation GdtRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super initWithSupplier:supplier adspot:adspot]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTUnifiedNativeAd alloc] initWithPlacementId:_supplier.adspotid];
        _gdt_ad.delegate = self;
    }
    return self;
}

- (void)supplierStateLoad {
    ADV_LEVEL_INFO_LOG(@"加载广点通 supplier: %@", _supplier);
    _supplier.state = AdvanceSdkSupplierStateInPull; // 从请求广告到结果确定前
    [_gdt_ad loadAd];
}

- (void)supplierStateInPull {
    ADV_LEVEL_INFO_LOG(@"广点通加载中...");
}

- (void)supplierStateSuccess {
    ADV_LEVEL_INFO_LOG(@"广点通 成功");
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)supplierStateFailed {
    ADV_LEVEL_INFO_LOG(@"广点通 失败");
    [self.adspot loadNextSupplierIfHas];
}


- (void)loadAd {
    [super loadAd];
}

- (void)deallocAdapter {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);
    if (self.gdt_ad) {
        self.gdt_ad.delegate = nil;
        self.gdt_ad = nil;
    }
}

- (void)dealloc {
    ADV_LEVEL_INFO_LOG(@"%s", __func__);

    [self deallocAdapter];
//    ADVLog(@"%s", __func__);
}

#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    
    if (error) {
        [self.adspot reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
        _supplier.state = AdvanceSdkSupplierStateFailed;
        if (_supplier.isParallel == YES) {
            return;
        }
    } else {
        GDTUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
        _supplier.supplierPrice = dataObject.eCPM;
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoBidding supplier:_supplier error:nil];
        [_adspot reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
        
        AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
        GdtRenderFeedAdView *gdtFeedAdView = [[GdtRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
        
        self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:gdtFeedAdView feedAdElement:element];
        
        if (_supplier.isParallel == YES) {
            _supplier.state = AdvanceSdkSupplierStateSuccess;
            return;
        }
        
        if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
            [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
        }
    }
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.desc;
    element.iconUrl = dataObject.iconUrl;
    if (dataObject.isThreeImgsAd) { // 三图
        element.imageUrlList = dataObject.mediaUrlList;
    } else { // 单图
        element.imageUrlList = @[dataObject.imageUrl];
    }
    element.mediaWidth = dataObject.imageWidth;
    element.mediaHeight = dataObject.imageHeight;
    element.buttonText = dataObject.buttonText;
    element.isVideoAd = [self isVideoAd:dataObject];
    element.videoUrl = dataObject.videoUrl;
    element.videoDuration = dataObject.duration;
    element.appRating = dataObject.appRating;
    return element;
}

- (BOOL)isVideoAd:(GDTUnifiedNativeAdDataObject *)dataObject {
    return [dataObject isVideoAd] || [dataObject isVastAd];
}

@end
