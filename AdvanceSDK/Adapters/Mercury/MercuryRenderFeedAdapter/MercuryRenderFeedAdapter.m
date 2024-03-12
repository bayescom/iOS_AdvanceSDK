//
//  MercuryRenderFeedAdapter.m
//  AdvanceSDK
//
//  Created by guangyao on 2024/3/11.
//

#import "MercuryRenderFeedAdapter.h"
#import <MercurySDK/MercuryUnifiedNativeAd.h>
#import "AdvanceRenderFeed.h"
#import "AdvLog.h"
#import "MercuryRenderFeedAdView.h"
#import "AdvRenderFeedAd.h"
#import "AdvanceAdapter.h"

@interface MercuryRenderFeedAdapter () <MercuryUnifiedNativeAdDelegate, AdvanceAdapter>

@property (nonatomic, strong) MercuryUnifiedNativeAd *mercury_ad;
@property (nonatomic, weak) AdvanceRenderFeed *adspot;
@property (nonatomic, strong) AdvSupplier *supplier;
@property (nonatomic, strong) AdvRenderFeedAd *feedAd;
 
@end

@implementation MercuryRenderFeedAdapter

- (instancetype)initWithSupplier:(AdvSupplier *)supplier adspot:(id)adspot {
    if (self = [super init]) {
        _adspot = adspot;
        _supplier = supplier;
        _mercury_ad = [[MercuryUnifiedNativeAd alloc] initAdWithAdspotId:_supplier.adspotid delegate:self];
    }
    return self;
}

- (void)loadAd {
    [_mercury_ad loadAd];
}

- (void)winnerAdapterToShowAd {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadingRenderFeedAd:spotId:)]) {
        [self.delegate didFinishLoadingRenderFeedAd:self.feedAd spotId:self.adspot.adspotid];
    }
}

- (void)dealloc {
    ADVLog(@"%s", __func__);
}

#pragma mark - MercuryUnifiedNativeAdDelegate

- (void)mercury_unifiedNativeAdLoaded:(NSArray<MercuryUnifiedNativeAdDataObject *> *)unifiedNativeAdDataObjects error:(NSError *)error {
    if (error) {
        [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoFailed supplier:_supplier error:error];
        [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdFailed];
        return;
    }
     
    MercuryUnifiedNativeAdDataObject *dataObject = unifiedNativeAdDataObjects.firstObject;
    AdvRenderFeedAdElement *element = [self generateFeedAdElementWithDataObject:dataObject];
    MercuryRenderFeedAdView *mercuryFeedAdView = [[MercuryRenderFeedAdView alloc] initWithDataObject:dataObject delegate:self.delegate adSpot:self.adspot supplier:self.supplier];
    self.feedAd = [[AdvRenderFeedAd alloc] initWithFeedAdView:mercuryFeedAdView feedAdElement:element];
    
    [self.adspot.manager setECPMIfNeeded:dataObject.price supplier:_supplier];
    [self.adspot.manager reportEventWithType:AdvanceSdkSupplierRepoSucceed supplier:_supplier error:nil];
    [self.adspot.manager checkTargetWithResultfulSupplier:_supplier loadAdState:AdvanceSupplierLoadAdSuccess];
}

- (AdvRenderFeedAdElement *)generateFeedAdElementWithDataObject:(MercuryUnifiedNativeAdDataObject *)dataObject {
    AdvRenderFeedAdElement *element = [[AdvRenderFeedAdElement alloc] init];
    element.title = dataObject.title;
    element.desc = dataObject.desc;
    element.iconUrl = dataObject.iconUrl;
    if (dataObject.isThreeImgsAd) { // 三图
        element.imageUrlList = dataObject.imageUrlList;
    } else if (dataObject.imageUrl.length) { // 单图
        element.imageUrlList = @[dataObject.imageUrl];
    }
    element.mediaWidth = dataObject.mediaWidth;
    element.mediaHeight = dataObject.mediaHeight;
    element.buttonText = dataObject.buttonText;
    element.isVideoAd = dataObject.isVideoAd;
    return element;
}

@end
