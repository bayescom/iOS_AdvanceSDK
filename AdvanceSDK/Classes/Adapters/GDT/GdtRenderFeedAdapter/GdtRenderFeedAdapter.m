//
//  GdtRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2023/9/8.
//

#import "GdtRenderFeedAdapter.h"
#import <GDTMobSDK/GDTMobSDK.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "GdtRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface GdtRenderFeedAdapter () <GDTUnifiedNativeAdDelegate, AdvanceAdapter>

@property (nonatomic, strong) GDTUnifiedNativeAd *gdt_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
 
@end

@implementation GdtRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _gdt_ad = [[GDTUnifiedNativeAd alloc] initWithPlacementId:_supplier.adspotid];
        _gdt_ad.delegate = self;
    }
    return self;
}

- (void)loadAd {
    [_gdt_ad loadAd];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}


#pragma mark - GDTUnifiedNativeAdDelegate
- (void)gdt_unifiedNativeAdLoaded:(NSArray<GDTUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    
    if (error) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
     
    GDTUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    GdtRenderFeedAdView *gdtFeedAdView = [[GdtRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:gdtFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:dataObject.eCPM supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
        
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(GDTUnifiedNativeAdDataObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.desc;
    element.iconUrl = dataObject.iconUrl;
    if (dataObject.isThreeImgsAd) { // 三图
        element.imageUrlList = dataObject.mediaUrlList;
    } else if (dataObject.imageUrl.length) { // 单图
        element.imageUrlList = @[dataObject.imageUrl];
    }
    element.mediaWidth = dataObject.imageWidth;
    element.mediaHeight = dataObject.imageHeight;
    element.buttonText = dataObject.buttonText;
    element.isVideoAd = [self isVideoAd:dataObject];
    element.videoDuration = dataObject.duration;
    element.appRating = dataObject.appRating;
    return element;
}

- (BOOL)isVideoAd:(GDTUnifiedNativeAdDataObject *)dataObject {
    return [dataObject isVideoAd] || [dataObject isVastAd];
}

@end
